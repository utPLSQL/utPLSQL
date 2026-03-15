-- Annotation Manager Volume Benchmark
-- 1000 generated packages, cold cache per iteration

set serveroutput on size unlimited
set timing off
set feedback off

declare
  c_packages         constant pls_integer := 1000;
  c_procs_per_pkg    constant pls_integer := 20;
  c_contexts_per_pkg constant pls_integer := 4;
  c_pkg_prefix       constant varchar2(20) := 'TST_GEN_PKG_';
  c_iterations       constant pls_integer := 4;
  c_perf_threshold   constant number      := 0.80;

  l_baseline_total_ms  number := 0;
  l_new_total_ms       number := 0;
  l_start              timestamp;
  l_elapsed            interval day to second;

  -- Source holders
  l_source_lines  dbms_preprocessor.source_lines_t;
  l_source_clob   clob;
  l_result        ut_annotations;

  -- Correctness tracking
  l_missing_from_cache pls_integer := 0;
  l_count_mismatches   pls_integer := 0;
  l_mismatch_detail    varchar2(32767);

  -- Cache check
  l_cursor         sys_refcursor;
  l_annotated_obj  ut_annotated_object;
  l_name           varchar2(128);
  l_annotations    ut_annotations;
  l_cache_count    pls_integer := 0;

  -- Per-package timing
  l_pkg_baseline_ms  number;
  l_pkg_new_ms       number;
  l_pkg              varchar2(30);
  l_ratio            number;

  -- Expected annotation count — mirrors generator logic exactly
  function expected_annotation_count(
    a_pkg_number pls_integer,
    a_procs      pls_integer,
    a_contexts   pls_integer
  ) return pls_integer is
    l_count pls_integer := 0;
  begin
    l_count := l_count + 2; -- %suite + %suitepath
    l_count := l_count + 2; -- %beforeall + %afterall
    l_count := l_count + 2; -- %beforeeach + %aftereach

    -- package level conditional
    if mod(a_pkg_number, 3) = 0 then l_count := l_count + 1; end if; -- %displayname
    if mod(a_pkg_number, 5) = 0 then l_count := l_count + 1; end if; -- %rollback

    -- contexts: each contributes %context + %endcontext
    l_count := l_count + (a_contexts * 2);

    -- per procedure
    for i in 1 .. a_procs loop
      l_count := l_count + 1;                                -- %test
      if mod(i, 3) = 0 then l_count := l_count + 1; end if; -- %tags
      if mod(i, 6) = 0 then l_count := l_count + 1; end if; -- %throws
      if mod(i, 8) = 0 then l_count := l_count + 1; end if; -- %disabled
      if mod(i, 5) = 0 then l_count := l_count + 2; end if; -- %beforetest + %aftertest
    end loop;

    return l_count;
  end expected_annotation_count;

begin
  dbms_output.put_line('Packages    : ' || c_packages);
  dbms_output.put_line('Procs/pkg   : ' || c_procs_per_pkg);
  dbms_output.put_line('Contexts/pkg: ' || c_contexts_per_pkg);
  dbms_output.put_line('Iterations  : ' || c_iterations);
  dbms_output.put_line('Started     : ' || to_char(systimestamp,'YYYY-MM-DD HH24:MI:SS.FF3'));

  -- Phase 1: Performance benchmark (cold cache per package per iteration)
  dbms_output.put_line(chr(10) || '-- Phase 1: Performance --');
  dbms_output.put_line(
    rpad('package',    20) || ' | ' ||
    lpad('baseline_ms', 11) || ' | ' ||
    lpad('new_ms',      6)  || ' | ' ||
    lpad('ratio',       5)  || ' | ' ||
    'status'
  );
  dbms_output.put_line(rpad('-', 70, '-'));

  for p in 1 .. c_packages loop
    l_pkg := c_pkg_prefix || lpad(p, 4, '0');

    -- load source once per package
    l_source_lines := dbms_preprocessor.get_post_processed_source(
      object_type => 'PACKAGE',
      schema_name => user,
      object_name => l_pkg
    );

    dbms_lob.createtemporary(l_source_clob, true);
    for i in 1 .. l_source_lines.count loop
      dbms_lob.writeappend(l_source_clob, length(l_source_lines(i)), l_source_lines(i));
    end loop;

    -- baseline: clob version
    l_pkg_baseline_ms := 0;
    for iter in 1 .. c_iterations loop
      ut_annotation_manager.purge_cache(user, 'PACKAGE');
      l_start := systimestamp;
      l_result := ut_annotation_parser.parse_object_annotations(l_source_clob);
      l_elapsed := systimestamp - l_start;
      l_pkg_baseline_ms := l_pkg_baseline_ms +
        extract(second from l_elapsed) * 1000;
    end loop;
    l_pkg_baseline_ms := l_pkg_baseline_ms / c_iterations;

    -- new: source_lines_t version
    l_pkg_new_ms := 0;
    for iter in 1 .. c_iterations loop
      ut_annotation_manager.purge_cache(user, 'PACKAGE');
      l_start := systimestamp;
      l_result := ut_annotation_parser.parse_object_annotations(l_source_lines);
      l_elapsed := systimestamp - l_start;
      l_pkg_new_ms := l_pkg_new_ms +
        extract(second from l_elapsed) * 1000;
    end loop;
    l_pkg_new_ms := l_pkg_new_ms / c_iterations;

    -- accumulate
    l_baseline_total_ms := l_baseline_total_ms + l_pkg_baseline_ms;
    l_new_total_ms      := l_new_total_ms      + l_pkg_new_ms;

    l_ratio := round(l_pkg_new_ms / nullif(l_pkg_baseline_ms, 0), 3);

    -- print every 100 packages to avoid flooding output
    if mod(p, 100) = 0 or p = 1 then
      dbms_output.put_line(
        rpad(l_pkg, 20)                       || ' | ' ||
        lpad(round(l_pkg_baseline_ms, 3), 11) || ' | ' ||
        lpad(round(l_pkg_new_ms, 3), 6)       || ' | ' ||
        lpad(l_ratio, 5)                      || ' | ' ||
        case when l_ratio <= c_perf_threshold
          then 'PASS (' || round((1-l_ratio)*100,1) || '% faster)'
          else 'SLOW (ratio=' || l_ratio || ')'
        end
      );
    end if;

    dbms_lob.freetemporary(l_source_clob);
  end loop;

  -- -------------------------------------------------------------------------
  -- Phase 1 summary
  -- -------------------------------------------------------------------------
  l_ratio := round(l_new_total_ms / nullif(l_baseline_total_ms, 0), 3);

  dbms_output.put_line(rpad('-', 70, '-'));
  dbms_output.put_line('Baseline total ms : ' || round(l_baseline_total_ms, 3));
  dbms_output.put_line('New total ms      : ' || round(l_new_total_ms, 3));
  dbms_output.put_line('Overall ratio     : ' || l_ratio);
  dbms_output.put_line('Improvement       : ' || round((1 - l_ratio) * 100, 1) || '%');

  -- Phase 2: Cache presence check
  dbms_output.put_line(chr(10) || '-- Phase 2: Cache presence --');

  ut_annotation_manager.purge_cache(user, 'PACKAGE');
  ut_annotation_manager.rebuild_annotation_cache(user, 'PACKAGE');

  -- query cache tables directly to avoid validate_annotation_cache side effects
  open l_cursor for
    select ut_annotated_object(
             i.object_owner, i.object_name, i.object_type, i.parse_time,
             cast(
               collect(
                 ut_annotation(
                   c.annotation_position, c.annotation_name,
                   c.annotation_text, c.subobject_name
                 ) order by c.annotation_position
               ) as ut_annotations
             )
           )
      from ut_annotation_cache_info i
      join ut_annotation_cache c on i.cache_id = c.cache_id
     where i.object_owner = user
       and i.object_type  = 'PACKAGE'
       and i.object_name like c_pkg_prefix || '%'
     group by i.object_owner, i.object_type, i.object_name, i.parse_time;

  loop
    fetch l_cursor into l_annotated_obj;
    exit when l_cursor%notfound;
    l_cache_count := l_cache_count + 1;
  end loop;
  close l_cursor;

  dbms_output.put_line('Expected in cache : ' || c_packages);
  dbms_output.put_line('Found in cache    : ' || l_cache_count);
  dbms_output.put_line('Cache check       : ' ||
    case when l_cache_count = c_packages
      then 'PASS — all ' || c_packages || ' packages found in cache'
      else 'FAIL — missing ' || (c_packages - l_cache_count) || ' packages from cache'
    end
  );

  -- Phase 3: Annotation count correctness
  dbms_output.put_line(chr(10) || '-- Phase 3: Annotation count correctness --');

  -- reopen same direct cache query for correctness check
  open l_cursor for
    select ut_annotated_object(
             i.object_owner, i.object_name, i.object_type, i.parse_time,
             cast(
               collect(
                 ut_annotation(
                   c.annotation_position, c.annotation_name,
                   c.annotation_text, c.subobject_name
                 ) order by c.annotation_position
               ) as ut_annotations
             )
           )
      from ut_annotation_cache_info i
      join ut_annotation_cache c on i.cache_id = c.cache_id
     where i.object_owner = user
       and i.object_type  = 'PACKAGE'
       and i.object_name like c_pkg_prefix || '%'
     group by i.object_owner, i.object_type, i.object_name, i.parse_time;

  loop
    fetch l_cursor into l_annotated_obj;
    exit when l_cursor%notfound;
    l_name        := l_annotated_obj.object_name;
    l_annotations := l_annotated_obj.annotations;

    declare
      l_pkg_number pls_integer;
      l_expected   pls_integer;
    begin
      l_pkg_number := to_number(substr(l_name, length(c_pkg_prefix) + 1));
      l_expected   := expected_annotation_count(
                        l_pkg_number,
                        c_procs_per_pkg,
                        c_contexts_per_pkg
                      );

      if l_annotations.count != l_expected then
        l_count_mismatches := l_count_mismatches + 1;
        if l_count_mismatches <= 10 then
          l_mismatch_detail := l_mismatch_detail || chr(10) ||
            '  ' || l_name ||
            ': expected=' || l_expected ||
            ' actual='   || l_annotations.count;
        end if;
      end if;
    end;
  end loop;
  close l_cursor;

  dbms_output.put_line('Packages checked  : ' || c_packages);
  dbms_output.put_line('Count mismatches  : ' || l_count_mismatches);
  if l_count_mismatches > 0 then
    dbms_output.put_line('Mismatch detail (first 10):' || l_mismatch_detail);
  end if;
  dbms_output.put_line('Count check       : ' ||
    case when l_count_mismatches = 0
      then 'PASS — all annotation counts match expected'
      else 'FAIL — ' || l_count_mismatches || ' packages have wrong annotation count'
    end
  );

  dbms_output.put_line(chr(10) || '=================================================');
  dbms_output.put_line('FINAL RESULTS');
  dbms_output.put_line('=================================================');
  dbms_output.put_line('Performance : ' ||
    case when l_ratio <= c_perf_threshold then 'PASS' else 'FAIL' end);
  dbms_output.put_line('Cache       : ' ||
    case when l_cache_count = c_packages then 'PASS' else 'FAIL' end);
  dbms_output.put_line('Counts      : ' ||
    case when l_count_mismatches = 0 then 'PASS' else 'FAIL' end);
  dbms_output.put_line('Overall     : ' ||
    case when l_ratio <= c_perf_threshold
          and l_cache_count = c_packages
          and l_count_mismatches = 0
      then 'PASS'
      else 'FAIL'
    end
  );
  dbms_output.put_line('Finished    : ' ||
    to_char(systimestamp, 'YYYY-MM-DD HH24:MI:SS.FF3'));
  dbms_output.put_line('=================================================');

  -- cleanup
  ut_annotation_manager.purge_cache(user, 'PACKAGE');

end;
/
