# Suite cache: collection hand-off patterns

How `ut_suite_cache_manager` and its callers move suite data between SQL statements through PL/SQL collections instead of joining tables directly, why that happens, and how to simplify it with the two tools now on the branch: code based access control (CBAC) and table SQL macros.

Revised on 2026-11-09 for the CBAC + SQL macro strategy, against branch `feature/code_based_access_control` at commit `05ab7423`. Line references point to that commit. Apart from the macro checks under [Rules for SQL macros](#rules-for-sql-macros-verified), nothing was measured on a live database. Statements marked **verify** need a test or a trace before anyone acts on them.

## Status at a glance

| Pattern | What it is | Status | Approach |
|---|---|---|---|
| P1 | access filter applied to a collection by the caller | open | access predicate in the `ut_suite_cache` query, plain SQL in `ut_suite_cache_manager` (CBAC) |
| P2 | chain of collection → collection functions | open | one statement with named CTEs |
| P3 | logical suites appended to a collection | open | CTE of the main statement |
| P4 | sort by self-join of a collection | open | last CTE of the main statement |
| P5 | paths reconciled against a collection | open | keep, over the single final result |
| P6 | collection → ref cursor → collection | **done, partly** | collection passed, no cursor; rows still converted to records (ORA-00600) |
| P7 | two scans of `ut_suite_cache` for path matching | open | one path-matching CTE |
| P8 | list handed between the two cache modules | **done** | table SQL macro `ut_annotation_cache_macros.get_cached_objects` |
| P9 | full rows loaded only to project scalars | open | Flow B reuses the main statement and projects |
| P10 | PL/SQL objects inserted through `table()` | keep | legitimate |
| P11 | short scalar lists joined in SQL | keep | legitimate |
| new | `get_cached_objects` branched on an argument's value | **done** | parameter removed (step 0) |

## Strategy: what CBAC and SQL macros are for

Until the CBAC commits, `ut_suite_cache_manager` and `ut_annotation_cache_manager` were `authid definer`. They could read the private cache tables, but `all_objects` inside them showed what the **framework owner** sees, not the **invoking user**. So the access checks ran in invoker-rights code (`ut_suite_manager`, `ut_annotation_manager`), which couldn't read the cache tables. The definer package selected cache rows into a collection, and the invoker package filtered that collection with `table(:coll)`. Most patterns below come from that split, or from code built around its output.

| Package | Before CBAC | Now |
|---|---|---|
| `ut_suite_cache_manager` | `authid definer` | `authid current_user` + CBAC role |
| `ut_annotation_cache_manager` | `authid definer` | `authid current_user` + CBAC role |
| `ut_annotation_manager` | `authid current_user` | unchanged + CBAC role (for the macro) |
| `ut_annotation_cache_macros` | did not exist | `authid definer` (macros can't be in invoker-rights packages) |
| `ut_suite_manager` | `authid current_user` | unchanged, no role |
| `ut_suite_tag_filter` | `authid definer` | unchanged, touches no tables |

The two tools solve different problems:

- **CBAC removes the reason for the split.** A cache manager now runs as the invoker and still reads its own tables. So one SQL statement inside it can join `ut_suite_cache` with `all_objects` as the invoking user sees it. **Within the module that owns the tables, use plain SQL.** It is compile-checked, needs no extra grants, and the optimizer sees real tables.
- **A table SQL macro is a cache module's read API for SQL owned by another module.** Use one only when a statement that belongs to another package must read the cache tables in the same statement. On the branch that is two places, both reading the annotation cache:
  - the `delete` in `ut_suite_cache_manager.remove_missing_objs_from_cache`;
  - the dynamic SQL in `ut_annotation_manager`, which joins the cache with `all_objects` / `dba_objects`.

  A macro costs:
  - a definer-rights package;
  - EXECUTE grants to the role and to the framework users;
  - the CBAC role on every caller;
  - the specs → grants → bodies install order.

  Add one only when such a cross-module read is needed (YAGNI).

**What this means for the suite read path.** Every cache read in Flows A and B already sits in `ut_suite_cache_manager`, so P1–P7 and P9 need no new macro. Only CBAC is needed, and it is already in place. `ut_suite_manager` keeps no role and names no cache table.

Rejected alternative: a `ut_suite_cache_macros` package that `ut_suite_manager` composes into its own statement. It would spread the role to `ut_suite_manager` and move knowledge of the cache's structure out of the module that owns it. It would also add a third macro grant, for no gain over a statement inside `ut_suite_cache_manager`.

## Rules for SQL macros (verified)

Consolidated from the checks on 19.20 EE, 21.3 XE and 23ai Free (2026-11-09).

1. **Table macros only.** The project requires 19c RU 19.20 or later. Table macros exist from 19.7, so they are available everywhere the framework runs. Scalar macros are not used.
2. **A macro can't live in an invoker-rights package.** Compiling one there fails with `PLS-00782`. Put macros in a separate `authid definer` package, such as `ut_annotation_cache_macros`.
3. **Callers need the CBAC role at compile time and at run time.** The macro is executed while the calling body compiles. `install.sql` therefore installs the specs, then runs [ut3_cbac_modify_objects_role_grants.sql](../source/ut3_cbac_modify_objects_role_grants.sql), then installs the bodies. With the old order, the bodies failed with `ORA-62565` / `PLS-00201`. The exact compile-time rule Oracle applies is an inference: one manual SYS compile succeeded without the role. The install order is the verified fix.
4. **Users need EXECUTE on the macro package.** On 21c XE, expanding a macro checks the calling user's own EXECUTE privilege. Without it the call fails with `ORA-62565` / `PLS-00904`. The role held by the calling package doesn't count there; on 19.20 and 23ai it was enough.
   - [create_grants.sql](../source/create_grants.sql) therefore grants `execute on ut_annotation_cache_macros`.
   - The grant exposes no data. A user with it still gets `ORA-01031` from the macro and from the table directly.
   - Every new macro package needs this grant, in addition to the role grant.
5. **The macro body sees an argument's value only when it is a literal.** For a PL/SQL variable or a bind variable, the body sees NULL; the value is bound only into the returned SQL text. Verified on 19.20 with a probe macro:

   | Call | Value seen in the macro body |
   |---|---|
   | literal `timestamp '2026-01-01 00:00:00'` | the value |
   | PL/SQL variable in static SQL | NULL |
   | bind in `execute immediate ... using` | NULL |

   So the body must not branch on argument values. Conditions go into the returned SQL text, for example `(a_x is null or col > a_x)`. This also matters for cursor sharing: the text is built once per call site, at hard parse.
6. **Collections can be arguments.** `from macro(sys.odcivarchar2list('a','b','c'))`, with `table(a_list)` in the macro text, returned 3 rows on 19.20. Not checked with framework types such as `ut_path_items`. The suite plan below doesn't need it.
7. **Qualify framework objects in the macro text** with `&&ut3_owner.`. The text is expanded into the caller's statement, and the caller is invoker rights.
8. **SYS can't call the macro directly.** It fails with `ORA-06598: insufficient INHERIT PRIVILEGES privilege`. This doesn't affect normal use.

## New finding: `get_cached_objects` branches on an argument's value

Commit `05ab7423` changed [ut_annotation_cache_macros.pkb:19](../source/core/annotations/ut_annotation_cache_macros.pkb:19) from the predicate `(i.parse_time > a_parsed_after or a_parsed_after is null)` to adding `and i.parse_time > a_parsed_after` only when `a_parsed_after is not null`. By rule 5, the effect depends on the caller:

- `remove_missing_objs_from_cache` passes the literal `null`. There is no filter, which is correct.
- `ut_annotation_manager.get_objects_to_refresh` passes the bind `:a_parsed_after`. The body sees NULL, so **the filter is never added**, even when `a_modified_after` has a value.

The results don't change. The outer query keeps a row when `o.last_ddl_time >= a_modified_after` and not `o.last_ddl_time < c.parse_time`. A cache row with `parse_time <= a_modified_after` can't fail the second test for an object that passes the first. With or without the filter, the same objects come back. Only the `parse_time` attribute of the returned list differs: it is now filled where the filter used to leave it null. No caller reads that attribute: `reset_objects_cache` and `get_sources_to_annotate` use only the names and `needs_refresh`. So the filter only trims the join input, and the commit's performance intent is not reached.

Resolved in step 0: `a_parsed_after` is removed from the macro, which keeps today's behaviour and simplifies the code. If a measurement later shows that the filter helps, restore it in the bind-safe form `(a_parsed_after is null or i.parse_time > a_parsed_after)`, which works for binds and literals. Rule 5 is now in the spec comment of `ut_annotation_cache_macros`.

## Data types involved

| Type | Shape | Notes |
|---|---|---|
| `ut_path_items` / `ut_path_item` | `schema_name, object_name, procedure_name, suite_path` | parsed run paths |
| `ut_suite_cache_rows` / `ut_suite_cache_row` | 22 attributes, the row type of table `ut_suite_cache` | **heavy**: 6 × `ut_executables`, 3 × `ut_varchar2_rows`, 1 × `ut_executable_test` |
| `ut_suite_items_info` | 10 scalars + `tags` | public output of `get_suites_info` |
| `ut_suite_items` | PL/SQL object tree (`ut_suite`, `ut_test`, ...) | built by `ut_suite_builder`, written by `save_object_cache` |
| `ut_annotation_objs_cache_info` | owner, name, type, `needs_refresh`, `parse_time` | lists of objects to refresh or remove |

Every `select value(c) ... bulk collect into ... from table(:coll) c` deep-copies each `ut_suite_cache_row`, nested tables included. Steps that only filter or reorder rows still copy all of their data.

## Flows

### Flow A: run (`ut_runner.run` → `ut_suite_manager.configure_execution_by_path`)

```
a_paths (ut_varchar2_list)
 │ resolve_schema_names              PL/SQL loop, normalises paths                        [suite_manager:52]
 │ refresh_cache per schema          see Flow C
 ▼
 get_schema_paths                                                                         [cache_manager:251]
 │ group_paths_by_schema             PL/SQL loop → ut_path_items                           [cache_manager:71]
 │ expand_paths                      SQL: table(paths) ⟕ ut_suite_cache → ut_path_items    [cache_manager:109]   ① scan of ut_suite_cache
 ▼
 get_cached_suite_data                                                                    [suite_manager:352]
 │ get_suite_items                   SQL: ut_suite_cache ⋈ table(paths) → rows            [cache_manager:180]   ② scan of ut_suite_cache, copy #1
 │ ut_suite_tag_filter.apply         dynamic SQL over table(rows) → rows                  [tag_filter:268]      copy #2 (only with tags)
 │ get_cached_suite_rows             SQL over table(rows) + generated logical suites       [cache_manager:256]   copy #3
 │ get_filtered_cursor               SQL over table(rows) ⋈ all_objects → rows            [suite_manager:299]   copy #4 (unless EXECUTE ANY)
 │ reconcile_paths_and_suites        SQL: table(paths) ⟕ table(rows) → raise errors        [suite_manager:328]
 │ sort_and_randomize_tests          recursive SQL over table(rows) ⋈ table(rows) → rows   [cache_manager:214]   copy #5
 │ open cursor for select * from table(rows)                                              [suite_manager:371]   copy #6 (fetch)
 ▼
 reconstruct_from_cache              bulk fetch limit 1000 → tt_cached_suites → object tree [suite_manager:253]
```

The cache table is read twice with nearly the same matching rules. The result set is then copied 4 to 6 times, through 5 SQL statements over `table()` collections, before it becomes the object tree. Unchanged since the CBAC commits.

### Flow B: suite info (`ut_runner.get_suites_info`, `ut_runner.has_suites`, ...)

```
a_paths → resolve_schema_names → refresh_cache per schema → get_schema_paths (①)         [suite_manager:566]
 │ get_cached_suite_info = get_cached_suite_rows(get_suite_items(paths))  (②, copies #1, #2) [cache_manager:404]
 │ get_filtered_cursor                                                     (copy #3)
 │ get_suite_items_info              SQL over table(rows) → ut_suite_items_info            (copy #4, projection) [cache_manager:411]
 ▼
 open cursor select value(c) from table(info) order by owner, name, line_no
```

Full rows, with all six executable lists, are loaded and copied three times, only to be projected to 10 scalar columns at the end. Tags are not applied here and the rows are not sorted.

### Flow C: cache refresh (`ut_suite_manager.refresh_cache`, [suite_manager:426](../source/core/ut_suite_manager.pkb:426))

```
get_schema_parse_time(owner)                                    scalar
ut_annotation_manager.get_annotated_objects(...)                sys_refcursor of ut_annotated_object
build_and_cache_suites                                                                     [suite_manager:383]
 │ fetch limit 10 → ut_annotated_objects
 │ per object: ut_suite_builder.create_suite_item_list → ut_suite_items (PL/SQL)
 │ per object: save_object_cache(ut_suite_items)                                          [cache_manager:279]
 │             autonomous tx: 2 × insert ... select from table(a_suite_items) with treat()
remove_missing_objs_from_cache(owner)                            one delete, macro (P8, done) [cache_manager:389]
```

### Flow D: smaller lookups

- `get_schema_ut_packages` → `get_cached_packages(ut_varchar2_rows)`: joins a short list of schema names with `ut_suite_cache_package` (P11).
- `suite_item_exists`: a scalar lookup in the cache manager, plus a separate `all_objects` check in [suite_manager:612](../source/core/ut_suite_manager.pkb:612). After step 3, the access predicate can move into the cache manager's query here too. Optional.

### The annotation flow (out of scope, checked)

After P8, `ut_annotation_manager` still passes `ut_annotation_objs_cache_info` lists:

- `get_non_existing_objects` → `remove_from_cache`;
- `get_objects_to_refresh` → `reset_objects_cache` and `get_sources_to_annotate`.

These are legitimate:

- The first list holds only dropped objects, so it is short.
- The second is used three times (count, reset, source query), so one materialisation is the cheaper form.

No change is planned.

## Pattern catalogue

### P1: select into a collection, filter by access in the caller

- **Where:** `get_suite_items` / `get_cached_suite_rows` (cache manager) → `get_filtered_cursor` ([ut_suite_manager.pkb:299](../source/core/ut_suite_manager.pkb:299)).
- **What:** cache rows are returned unfiltered ("Returned data is not filtered by user access rights" in the spec). The caller filters the collection against `all_objects`.
- **Why it exists:** the definer/invoker split. CBAC removed it.
- **Cost:**
  - A full copy of the result set, plus a union of two scans of the same collection.
  - Logical suites are exempted (`or c.self_type = 'UT_LOGICAL_SUITE'`) because they are generated before the filter runs. **Verify:** this can leave logical suites with no accessible children in the tree.
- **Name:** `get_filtered_cursor` is misleading: it returns a collection, not a cursor.
- **Approach:** put the access predicate into the `ut_suite_cache` query inside `ut_suite_cache_manager`. That is plain SQL; no macro is needed. The EXECUTE ANY / `a_skip_all_objects` decision comes in as a bind flag in the SQL text (rule 5 doesn't apply here, but the same style keeps one cursor):
  ```sql
  where ( :skip_access_check = 'Y'
          or c.object_owner = sys_context('userenv','current_user')
          or exists (select 1 from all_objects a
                      where a.owner = c.object_owner and a.object_name = c.object_name
                        and a.object_type = 'PACKAGE') )
  ```
  Logical suites are then generated from accessible suites only, and the exemption goes away.

### P2: chain of collection-to-collection transforms

- **Where:** Flow A, copies #1 → #5. Each step is a function `f(ut_suite_cache_rows) return ut_suite_cache_rows` with one `select ... from table(:coll)`.
- **Cost:**
  - Repeated deep copies of heavy objects.
  - No predicate pushing across steps.
  - Unknown `table()` cardinality: only two statements carry a fixed `cardinality(c 500)` hint.
  - `value(c)` is moved around instead of columns.
- **Approach:** one statement in `ut_suite_cache_manager`, with each step as a named CTE. It carries columns, not objects, and the final select returns columns that the caller fetches into records for `reconstruct_from_cache`. Don't use `ut_suite_cache_row` objects here; see the `ORA-00600` under P6. It is dynamic SQL because of the tag predicate (see the target design). `ut_suite_tag_filter` keeps only the predicate builder.

### P3: enrich a collection with generated rows

- **Where:** cursor `c_get_bulk_cache_suite` ([ut_suite_cache_manager.pkb:22](../source/core/ut_suite_cache_manager.pkb:22)), used by `get_cached_suite_rows`.
- **What:** logical suites (path prefixes with no package behind them) are derived from the selected suites and appended with `union all`, through a full object constructor with null-cast executables.
- **Notes:**
  - Path depth is capped by `xmltable('1 to 20')`. **Verify** what happens beyond 20 levels: logical parents above level 20 would be missing.
  - Levels are counted with `regexp_count(path, '\w+')`, which does not count `$` and `#`, both allowed in path parts.
- **Approach:** a CTE of the main statement, placed after the access and tag filters.

### P4: in/out collection reorder with a self-join

- **Where:** `sort_and_randomize_tests` ([ut_suite_cache_manager.pkb:214](../source/core/ut_suite_cache_manager.pkb:214)).
- **What:** a recursive CTE walks the hierarchy over `table(a_suite_rows)`, then joins back to `table(a_suite_rows)` to recover the objects. The result is copied and assigned back to the in/out parameter.
- **Cost:** two scans of the collection plus one copy. `ut_utils.hash_suite_path` is called from SQL for each row (`ut_utils` is granted to the role).
- **Approach:** the last CTE of the main statement, with `order by order1 desc` as the final `order by`.

### P5: validate by joining two collections

- **Where:** `reconcile_paths_and_suites` ([ut_suite_manager.pkb:328](../source/core/ut_suite_manager.pkb:328)).
- **What:** expanded paths are left-joined to the final rows to find paths that matched nothing. The first one raises an error.
- **Note:** this runs **after** the tag and access filters. As the code reads, a package path whose tests are all excluded by tags raises "Suite package ... does not exist". **Verify** whether this is intended and covered by tests (open question 1). Any reordering must keep this behaviour.
- **Approach:** keep it as one small check over the single final collection. It is cheap once P2 is done.

### P6: collection → ref cursor → collection

- **Where:** `get_cached_suite_data` opens `select * from table(l_filtered_rows)` ([ut_suite_manager.pkb:371](../source/core/ut_suite_manager.pkb:371)). `reconstruct_from_cache` fetches it back in batches of 1000.
- **What:** a fully materialised collection is wrapped in a cursor and unwrapped again. `limit 1000` saves no memory.
- **Done in step 2, partly.**
  - `get_cached_suite_data` returns the collection.
  - `reconstruct_from_cache` takes it and converts it to records with one `select * bulk collect into` from `table()`.
  - The ref cursor type `t_cached_suites_cursor` and the `limit 1000` batch loop are gone.
- **Why the record conversion stays:** building the `ut_test` objects straight from the `ut_suite_cache_row` objects makes nested runs fail on 19.20. See [Records, not objects, for building the tree](#records-not-objects-for-building-the-tree). So the copy from the collection into `tt_cached_suites` records remains, and so do `c_cached_suites_cursor` and `tt_cached_suites`.

#### Records, not objects, for building the tree

Found in step 2, on 19.20 EE, 2026-11-09:

- **Symptom:** `reconstruct_from_cache` read the rows straight from the `ut_suite_cache_rows` collection, and `get_logical_suite` built `ut_test(item => <row>.item, ...)` from `ut_suite_cache_row` objects. A nested run then failed with `ORA-00600: [pfrobj.c: invalid RTTI for Object]`.
  - The run was `test_ut_test.application_info_on_execution`, which calls `ut3_develop.ut.run`.
  - The error was raised in `UT3_DEVELOP.UT_EXECUTABLE.DO_EXECUTE` line 49, the call on the test's `item` (`ut_executable_test`, `authid current_user`). The location comes from the incident trace's PL/SQL call stack.
  - It reproduced every time, and killed the whole test run.
- **Variants that still failed:**
  - the rows assigned to a local variable before the call;
  - `pragma inline` removed;
  - each row copied into a local `ut_suite_cache_row` variable;
  - the collection kept in a package variable, so it is never freed;
  - an extra `select value(c) bulk collect` round trip in `ut_suite_manager`, which has no CBAC role.
- **Variant that worked:** the same rows, converted with `select * bulk collect into` a collection of `c_cached_suites_cursor%rowtype` records. With that, `test_ut_test` (27 tests) and the full run (1136 tests) passed.
- **Rule for later steps:** build the suite tree from records whose columns SQL filled, not from attributes of `ut_suite_cache_row` objects. The cause looks like an Oracle defect; it was not narrowed down further.

### P7: two passes over `ut_suite_cache` for path resolution

- **Where:** `expand_paths` ([ut_suite_cache_manager.pkb:109](../source/core/ut_suite_cache_manager.pkb:109)) and `get_suite_items` ([ut_suite_cache_manager.pkb:180](../source/core/ut_suite_cache_manager.pkb:180)).
- **What:** `expand_paths` resolves wildcards into concrete paths (4 CTEs, `union all`, `row_number` dedup), back into a collection. `get_suite_items` then joins that with `ut_suite_cache` again, with similar `like`/`nvl` matching and another dedup.
- **Cost:** two scans, and three places that encode "how a path matches a cache row" (`expand_paths`, `get_suite_items`, `reconcile_paths_and_suites`), each slightly differently. This is the hardest part of the code to reason about.
- **Note:** the `where` clause of `get_suite_items` mixes `and`/`or` without full parentheses. It works because `null || '.%'` can't match a real path, not because of the structure.
- **Approach:** one "path → matching cache rows" CTE in the main statement, with one definition of the matching rules. `group_paths_by_schema` stays a PL/SQL parser, and its `ut_path_items` stays a bind (P11). `reconcile` uses the same CTE (paths with no match).

### P8: list handed over between two cache modules (done)

- **Before:** `ut_annotation_cache_manager.get_cached_objects_list` returned a collection. The not-cached package names went into a second collection, which drove two `delete ... in (table())`.
- **Now:** one `delete` from `ut_suite_cache_package` ([ut_suite_cache_manager.pkb:389](../source/core/ut_suite_cache_manager.pkb:389)). It reads the annotation cache through `ut_annotation_cache_macros.get_cached_objects` and relies on the `on delete cascade` FK for `ut_suite_cache`. `get_missing_cache_objects` and `get_cached_objects_list` are gone.
- **Follow-up, also done:** `ut_annotation_manager.get_non_existing_objects` and `get_objects_to_refresh` select from the same macro in their dynamic SQL, joined directly with `all_objects` / `dba_objects`. No collection is bound, and the `cardinality` hints are gone. `ut_annotation_cache_info` became an index-organised table keyed by `(object_owner, object_type, object_name)` (commit `4d6be442`), which matches the macro's predicate.
- **Step 0, done:** the macro takes only `(a_object_owner, a_object_type)`; the `a_parsed_after` branch is gone (see the new finding).

### P9: full rows loaded only to project scalars

- **Where:** Flow B: `get_cached_suite_info` → `get_filtered_cursor` → `get_suite_items_info`.
- **What:** `ut_suite_cache_row` objects, with all executable lists, are built and copied only to produce `ut_suite_item_info`.
- **Approach:** after P1/P2/P7, Flow B runs the same statement text as Flow A, without tags or randomisation. It differs only in the final select (`ut_suite_item_info(...)`, ordered by owner, name and line). The statement is built in one private function, and the two flows add their own final select (DRY). `get_cached_suite_info` and `get_suite_items_info` then leave the spec (Interface Segregation).

### P10: PL/SQL-built objects written through `table()` (legitimate)

- **Where:** `save_object_cache` ([ut_suite_cache_manager.pkb:279](../source/core/ut_suite_cache_manager.pkb:279)).
- `ut_suite_builder` builds object trees in PL/SQL, and inserting them through `table(a_suite_items)` with `treat()` is the natural way to persist them. **Keep it.**
- Optional: the two `insert ... select` statements (suites and contexts, then tests) could become one, at some cost to readability.
- The `delete` before the inserts must stay. The package row is updated, not re-created, so the FK cascade doesn't fire there.

### P11: short scalar lists joined in SQL (legitimate)

`get_cached_packages(table(a_schema_names))` and the path list are small lists of user input, joined in SQL. **Keep them.**

## Smaller findings seen along the way

1. **Rollback type is set twice. Fixed in step 2:** only `reconstruct_from_cache` sets it now. That covers `configure_execution_by_path` and `build_suites_from_annotations`.
2. **Duplicated prologue.** `configure_execution_by_path` and `get_suites_info` both do "resolve schema names → refresh cache per schema → `get_schema_paths`". This could be one private procedure.
3. **Two near-identical checks.** `can_skip_all_objects_scan` ([ut_suite_manager.pkb:376](../source/core/ut_suite_manager.pkb:376)) and the `user_has_execute_any_proc() or a_skip_all_objects` test in `get_filtered_cursor` cover almost the same check. After step 3, one function computes the skip flag.
4. **`get_logical_suite` repeats constructor calls.** It holds 7 constructor calls that differ only in `items =>`. Choosing `items` first would cut it to 4.
5. **Possible stale items on a bad suitepath (verify).** In `build_and_cache_suites` ([ut_suite_manager.pkb:398](../source/core/ut_suite_manager.pkb:398)), when `create_suite_item_list` raises `ex_string_too_small`, `save_object_cache` still runs with `l_suite_items`. That parameter is `out nocopy`, so it may hold partial or previous-object items.
6. **Arbitrary `row_number` order.** `get_suite_items` deduplicates with `order by path, object_owner` inside a partition by the same columns. That is fine only because the duplicates are identical rows.

## Target design

```
ut_suite_manager (invoker, no role)                ut_suite_cache_manager (invoker + CBAC)
-----------------------------------                --------------------------------------
resolve paths, refresh cache   ──paths, tags──▶    get_suite_rows(a_paths, a_tags, a_random_seed, a_skip_access_check)
                                                     one dynamic statement (tag predicate or 1 = 1), CTEs:
                                                       path_items      table(:paths), wildcards expanded  ← P7
                                                       matched_rows    ut_suite_cache ⋈ path_items
                                                                       + access predicate (all_objects)  ← P1
                                                       tagged_rows     tag predicate from the tag filter ← P2
                                                       with_logical    generated logical suites          ← P3
                                                       ordered         recursive sort / randomise        ← P4
                                   ◀──rows──────     rows fetched as records (tt_cached_suites), not objects
reconcile(paths, rows)                                                                                   ← P5
reconstruct_from_cache(rows)       no ref cursor                                                         ← P6

get_suites_info                ──paths──────▶      get_suite_info(a_paths, a_skip_access_check)
                                                     the same statement text, no tags, no sort,
                                   ◀──cursor────     final select ut_suite_item_info, ordered            ← P9

ut_suite_tag_filter: only create_where_filter (tag expression → SQL predicate). apply / get_tags_suites go.
ut_annotation_cache_macros: unchanged; the only macro package.
```

Notes:

- **The tag filter is the only reason for dynamic SQL.** The statement is built once, with the tag predicate or `1 = 1`, and executed with binds. Its framework names are qualified with `&&ut3_owner.`: SQL*Plus substitutes them in string literals at install time too. Today's tag SQL uses an unqualified `ut_varchar2_rows`, which must be qualified when it moves. All types it uses are already granted to the role (`ut_varchar2_rows`, `ut_suite_cache_row`, `ut_suite_item_info`, `ut_utils`).
- **Tag propagation** (`propagate_tags_from_ancestors`) is already a self-join over the matched rows, and it moves as a CTE.
- **Readability:** name each CTE after the function it replaces.
- **No new privileges.** `ut_suite_cache_manager` already holds the role. `ut_suite_manager` and `ut_suite_tag_filter` need none, and no new grant lines are needed.

## Suggested steps (each can ship and be tested separately)

0. **Remove the `a_parsed_after` branch from `get_cached_objects`. Done.**
   - The parameter is gone from the macro and from its three call sites: `remove_missing_objs_from_cache`, `get_non_existing_objects` and `get_objects_to_refresh`. The last one now binds three values instead of four. Its freshness check `case when o.last_ddl_time < cast(c.parse_time as date) then 'N' else 'Y' end = 'Y'` is now written as `(c.parse_time is null or o.last_ddl_time >= cast(c.parse_time as date))`, with the same meaning. It stays in the `where` clause: moved into the `on` clause of the left join, it would no longer drop any row, and every object would be re-parsed on each refresh.
   - Rule 5 is documented in the spec of `ut_annotation_cache_macros`.
   - **Verified on 2026-11-09:**
     - Setup: a fresh container of `utplsqlv3/oracledb:19.20-utplsql`, then `development/install.sh` and `test/install_tests.sh`.
     - Install: no invalid objects; the three packages hold the role.
     - Full run: 1136 tests, 0 failed, 0 errored, 3 disabled.
     - The result doesn't change by design, so the tests are a safety net, not a proof of the effect.
1. **P8, done.** Single `delete` through the macro, plus the follow-up in `ut_annotation_manager`.
   - Verified on 19.20 EE (1136 tests), 21.3 XE (1143) and 23ai, all with 0 failed and 3 disabled.
   - The 19.20 and 23ai runs are from before the 21c `create_grants.sql` fix, and were not rerun locally after it.
   - **Not checked:** which tests make the difference between 1136 and 1143.
2. **P6 + finding 1. Done, partly.** `reconstruct_from_cache` takes the collection instead of a ref cursor, and the rollback type is set once.
   - The rows are still converted to records, because of the `ORA-00600` described under P6.
   - Verified on 2026-11-09 on 19.20 EE: install with no invalid objects, and the full run passed (1136 tests, 0 failed, 0 errored, 3 disabled).
   - Consequence for step 4: the main statement should return columns that are fetched into records, not `ut_suite_cache_row` objects. That also removes the last copy, the conversion in `reconstruct_from_cache`.
3. **P1: access predicate into `get_suite_items`** (plain SQL in `ut_suite_cache_manager`).
   - Remove `get_filtered_cursor` and the logical-suite exemption, and merge finding 3.
   - Check the `build_suites_from_annotations(a_skip_all_objects)` path used by `test_suite_builder`.
   - Answer open question 2 first with a test, because this step changes that behaviour by construction.
4. **P2/P3/P4: one statement.** Merge `get_suite_items` → tags → logical suites → sort into one dynamic statement, and reduce `ut_suite_tag_filter` to `create_where_filter`. Rewrite the `apply` tests in `test_ut_suite_tag_filter` against the new entry point; don't keep `apply` as a test-only wrapper (YAGNI).
5. **P7: merge `expand_paths` into the path CTE.** This is the riskiest step. Wildcard semantics and error messages are covered by `test_ut_run` / `test_ut_runner` in `ut3_user`. Do it last among the merges, with those suites as the safety net.
6. **P9: Flow B on the same statement text.** Remove `get_cached_suite_info` and `get_suite_items_info` from the spec, and merge finding 2.

## Bigger options to consider separately

- **Materialise logical suites in the cache.** Insert `UT_LOGICAL_SUITE` rows into `ut_suite_cache`, per schema, at the end of `refresh_cache`. Run-time queries then become plain table reads, and P3 leaves the read path.
  - Cost: logical rows depend on every package in the schema, so they need a rebuild whenever any package's suitepath changes.
  - The unique keys on `(object_owner, path)` and `(object_owner, object_name, line_no)` must accommodate them.
  - With P1 applied at read time, logical rows would also need an access rule of their own.
- **Stream instead of materialise.** If reconciliation (P5) can be answered from the path CTE alone, the main statement can be returned as a real cursor, and `reconstruct_from_cache` can fetch in batches. That depends on open question 1.

## How to check that nothing regressed

- **Behaviour:** the full `ut3_tester` and `ut3_user` suites, especially:
  - `test_suite_builder`;
  - `test_ut_suite_tag_filter`;
  - `test_ut_run` (paths, wildcards, tags, random order);
  - `test_ut_runner` (`get_suites_info`, `has_suites`, `is_suite`, `is_test`);
  - `test_annotation_cache`, which runs as users without elevated privileges.
- **Platforms:** 19.20, 21.3 XE and 23ai, because macro privilege checks differ between versions (rules 3 and 4).
- **Performance:** compare before and after on a schema with many suites, using the `ut_event_manager` events `configure_execution_by_path - start/end` and `development/mystats`.

## Open questions

1. Should a package path whose tests are all excluded by tags raise "does not exist" (P5)?
2. Can logical suites currently remain in the tree with no accessible children (P1)? If so, is that intended? Step 3 removes them by construction.
3. Is the 20-level limit on suitepath depth (P3) documented anywhere, or is it accidental?
4. Would a `parse_time` filter in `get_objects_to_refresh` pay off (removed in step 0)? Only a measurement on a schema with many cached objects can tell. If it would, use the bind-safe form.
