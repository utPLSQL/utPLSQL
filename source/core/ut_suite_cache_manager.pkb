create or replace noneditionable package body ut_suite_cache_manager is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2026 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  /*
  * Private code
  */
  function group_paths_by_schema(a_paths ut_varchar2_list) return ut_path_items is
    c_package_path_regex constant varchar2(100) := '^([[:alnum:]$#_]+)(\.([[:alnum:]$#_\*]+))?(\.([[:alnum:]$#_\*]+))?$';
    l_results            ut_path_items := ut_path_items();
    l_path_item          ut_path_item;
    i                    pls_integer;
  begin
    i := a_paths.first;
    while (i is not null) loop
      l_results.extend;     
      if a_paths(i) like '%:%' then
        l_path_item := ut_path_item(schema_name => upper(regexp_substr(a_paths(i),'^[^.:]+')),
                                    suite_path => ltrim(regexp_substr(a_paths(i),'[.:].*$'),':'));
        l_results(l_results.last) := l_path_item;
      else
        l_path_item := ut_path_item(schema_name => regexp_substr(a_paths(i), c_package_path_regex, subexpression => 1),  
                                    object_name => regexp_substr(a_paths(i), c_package_path_regex, subexpression => 3),
                                    procedure_name => regexp_substr(a_paths(i), c_package_path_regex, subexpression => 5));
        l_results(l_results.last) := l_path_item;
      end if;
      i := a_paths.next(i);
    end loop;
    
    return l_results;
  end;
  
  /*
    First SQL queries for objects where procedure is null or its only wildcard.
    We split that due to fact that we can use func min to combine rows.
    
    Second union is responsible expanding paths where the procedure filter is given
    We cannot select min here as filter can cover only half of tests within
    package. Even if the filter doesnt return anything we still capture a proc filter
    name for error reporting later on.
    
    Third SQL cover scenario where a suitapath only is populated and wildcard is given
    
    Fourth SQL cover scenario where suitepath is populated with no filters
  */   
  function expand_paths(a_schema_paths ut_path_items) return ut_path_items is
    l_schema_paths ut_path_items:= ut_path_items();
  begin   
    with 
      schema_paths as (
      select * from table(a_schema_paths)
    ),    
      paths_for_object as ( 
      select /*+ no_parallel */ min(path) as suite_path,sp.schema_name as schema_name,nvl(c.object_name,sp.object_name) as object_name,
        null as procedure_name
        from schema_paths sp left outer join &&ut3_owner..ut_suite_cache c
        on ( c.object_owner = upper(sp.schema_name)
        and c.object_name like  replace(upper(sp.object_name),'*','%'))
        where sp.suite_path is null and sp.object_name is not null
        and ( sp.procedure_name is null or sp.procedure_name = '*')
        group by sp.schema_name,nvl(c.object_name,sp.object_name)
      ),
      paths_for_procedures as (
      select /*+ no_parallel */ path as suite_path,sp.schema_name as schema_name,nvl(c.object_name,sp.object_name) as object_name,
        nvl(c.name,sp.procedure_name) as procedure_name
        from schema_paths sp left outer join &&ut3_owner..ut_suite_cache c
        on ( c.object_owner = upper(sp.schema_name)
        and c.object_name like  replace(upper(sp.object_name),'*','%')
        and c.name like nvl(replace(upper(sp.procedure_name),'*','%'), c.name))
        where sp.suite_path is null and sp.object_name is not null
        and (sp.procedure_name is not null and sp.procedure_name != '*')      
      ),
      paths_for_suite_path_with_ast as (
      select /*+ no_parallel */ nvl(c.path,sp.suite_path) as suite_path,sp.schema_name,sp.object_name,sp.procedure_name as procedure_name
        from schema_paths sp left outer join &&ut3_owner..ut_suite_cache c on
        ( c.object_owner = upper(sp.schema_name) 
        --and c.path like replace(sp.suite_path,'*','%'))
        and regexp_like(c.path,'^'||replace(sp.suite_path,'*','[[:alnum:]$#_]*')))
        where sp.suite_path is not null and instr(sp.suite_path,'*') > 0
      ),
      straigth_suite_paths as (
      select /*+ no_parallel */ sp.suite_path as suite_path,sp.schema_name,sp.object_name,sp.procedure_name as procedure_name
       from schema_paths sp
       where 
       (sp.suite_path is not null and instr(sp.suite_path,'*') = 0)
       or 
       (sp.suite_path is null and sp.object_name is null)
    ),
    all_suitepaths_together as (
    select * from paths_for_object
    union all
    select * from paths_for_procedures
    union all
    select * from paths_for_suite_path_with_ast
    union all 
    select * from straigth_suite_paths
    )
    select &&ut3_owner..ut_path_item(schema_name,object_name,procedure_name,suite_path)
      bulk collect into l_schema_paths
      from 
      (select schema_name,object_name,procedure_name,suite_path,
      row_number() over ( partition by schema_name,object_name,procedure_name,suite_path order by 1) as r_num
      from all_suitepaths_together)
      where r_num = 1 ;
    return l_schema_paths;
  end;
  
  /*
  * Public code
  */
  
  function get_schema_paths(a_paths in ut_varchar2_list) return ut_path_items is
  begin
    return expand_paths(group_paths_by_schema(a_paths));
  end;
  
  /*
    Returns suite items for the paths in one statement, sorted bottom up, so that reconstruct_from_cache in ut_suite_manager
    can build the suite hierarchy in a single pass. The statement:
    - matched_rows:   cache rows matching the paths (all parents and children of a suite path, or the package / procedure),
                      only for packages the invoking user can access, unless a_skip_access_check is true
    - tagged_rows:    when tags are given, the rows having a test matching the tag expression below them (or being one);
                      a test inherits the tags of the suites and contexts above it
    - logical_suites: suites for the parts of the suitepaths that have no package behind them
    - ordered:        the hierarchy sorted depth first by line number, or by a hash of the path when a_random_seed is given
    The tag expression is evaluated per test by ut_suite_tag_filter.is_matching, so the statement is static SQL.
  */
  function get_suite_rows(
    a_schema_paths       ut_path_items,
    a_skip_access_check  boolean,
    a_tags               varchar2 := null,
    a_random_seed        positive := null
  ) return ut_suite_cache_rows is
    l_results            ut_suite_cache_rows;
    l_skip_access_check  varchar2(1) := case when a_skip_access_check then 'Y' else 'N' end;
  begin
    with
      matched_rows as (
        select /*+ no_parallel */ c.id, c.self_type, c.path, c.object_owner, c.object_name, c.line_no, c.tags
          from &&ut3_owner..ut_suite_cache c
         where exists (
                 select /*+ no_expand */ 1
                   from table(a_schema_paths) sp
                  where c.object_owner = upper(sp.schema_name)
                    and ( ( sp.suite_path is not null
                            and ( sp.suite_path||'.' like c.path||'.%' /* all parents and self */
                                  or ( c.path||'.' like sp.suite_path||'.%' /* all children and self */
                                       and c.object_name like nvl(upper(sp.object_name),c.object_name)
                                       and c.name like nvl(upper(sp.procedure_name),c.name)
                                     )
                                )
                          )
                          or ( sp.suite_path is null
                               and c.object_name = nvl(upper(sp.object_name),c.object_name)
                               and c.name = nvl(upper(sp.procedure_name),c.name)
                             )
                        )
               )
           and ( l_skip_access_check = 'Y'
                 or exists (
                      select 1
                        from all_objects a
                       where a.owner       = c.object_owner
                         and a.object_name = c.object_name
                         and a.object_type = 'PACKAGE'
                    )
               )
      ),
      propagate_tags_from_ancestors as (
        select c.id, c.self_type, c.path, c.object_owner, listagg(distinct c_tags.tag, ',') within group (order by c_tags.tag) as tags
          from matched_rows c
          left join matched_rows t
            on t.self_type in ('UT_SUITE','UT_SUITE_CONTEXT')
           and c.path like t.path||'.%' /* all descendants */
           and c.object_owner = t.object_owner
         outer apply (select column_value tag from table(c.tags) union select column_value tag from table(t.tags) ) c_tags
         where c.self_type = 'UT_TEST'
         group by c.id, c.self_type, c.path, c.object_owner
      ),
      filter_by_tags as (
        select x.path, x.object_owner
          from propagate_tags_from_ancestors x
         where &&ut3_owner..ut_suite_tag_filter.is_matching(x.tags, a_tags) = 1
      ),
      tagged_rows as (
        select /*+ no_expand */ item.*
          from matched_rows item
         where a_tags is null
            or exists (
                 select 1
                   from filter_by_tags tst
                  where tst.path||'.' like item.path || '.%' /* all descendants and self */
                    and tst.object_owner = item.object_owner
               )
      ),
      suitepaths as (
        select distinct substr(c.path,1,instr(c.path,'.',-1)-1) as suitepath, c.path, c.object_owner
          from tagged_rows c
         where c.self_type = 'UT_SUITE'
      ),
      gen as (
        --not xmltable('1 to 20'): together with the recursive "ordered" below it makes the parse hang or fail with ORA-07445 [qmxtrProcCorrOpn] on 19.20
        select level as pos from dual connect by level <= 20
      ),
      suitepath_part as (
        select distinct substr(b.suitepath, 1, instr(b.suitepath || '.', '.', 1, g.pos) -1) as path, b.object_owner
          from suitepaths b
          join gen g
            on g.pos <= regexp_count(b.suitepath, '\w+')
      ),
      logical_suites as (
        select p.path, p.object_owner, upper( substr(p.path, instr( p.path, '.', -1 ) + 1 ) ) as object_name
          from suitepath_part p
         where p.path not in (select s.path from suitepaths s)
      ),
      all_items as (
        select t.id, t.path, t.object_owner, t.object_name, t.line_no
          from tagged_rows t
        union all
        select null as id, l.path, l.object_owner, l.object_name, null as line_no
          from logical_suites l
      ),
      items_for_sort as (
        select a.id, a.path, substr(a.path,1,instr(a.path,'.',-1,1)-1) as parent_path, a.object_owner, a.object_name,
               case when a_random_seed is null then a.line_no end as line_no,
               case when a_random_seed is not null then &&ut3_owner..ut_utils.hash_suite_path(a.path, a_random_seed) end as random_seed
          from all_items a
      ),
      ordered(id, path, parent_path, object_owner, object_name, line_no, random_seed) as (
        select s.id, s.path, s.parent_path, s.object_owner, s.object_name, s.line_no, s.random_seed
          from items_for_sort s
         where s.parent_path is null
        union all
        select s.id, s.path, s.parent_path, s.object_owner, s.object_name, s.line_no, s.random_seed
          from ordered o
          join items_for_sort s
            on s.parent_path = o.path
           and s.object_owner = o.object_owner
      )
      --path, object_owner: siblings with the same line number (packages, logical suites) keep the order of their paths
      search depth first by line_no desc, random_seed desc nulls last, path, object_owner set order1
    select /*+ no_parallel */
           case
             when o.id is not null then value(c)
             else &&ut3_owner..ut_suite_cache_row(
                    null, 'UT_LOGICAL_SUITE', o.path, o.object_owner, o.object_name, o.object_name,
                    null, null, null, null, 0, null,
                    &&ut3_owner..ut_varchar2_rows(),
                    null, null, null, null, null, null,
                    null, null, null
                  )
           end
      bulk collect into l_results
      from ordered o
      left join &&ut3_owner..ut_suite_cache c
        on c.id = o.id
     order by o.order1 desc;

    return l_results;
  end;

  function get_schema_parse_time(a_schema_name varchar2) return timestamp result_cache is
    l_cache_parse_time timestamp;
  begin
    select /*+ no_parallel */ min(t.parse_time)
      into l_cache_parse_time
      from &&ut3_owner..ut_suite_cache_schema t
     where object_owner = upper(a_schema_name);
    return l_cache_parse_time;
  end;

  procedure save_object_cache(
    a_object_owner varchar2,
    a_object_name  varchar2,
    a_parse_time   timestamp,
    a_suite_items ut_suite_items
  ) is
    pragma autonomous_transaction;
    l_cached_parse_time timestamp;
    l_object_owner      varchar2(250) := upper(a_object_owner);
    l_object_name       varchar2(250) := upper(a_object_name);
  begin
    if a_suite_items is null or a_suite_items.count = 0 then

      --rows of ut_suite_cache are removed by the "on delete cascade" foreign key
      delete from &&ut3_owner..ut_suite_cache_package t
       where t.object_owner = l_object_owner
         and t.object_name = l_object_name;

    else

      select /*+ no_parallel */ min(parse_time)
        into l_cached_parse_time
        from &&ut3_owner..ut_suite_cache_package t
       where t.object_name = l_object_name
         and t.object_owner = l_object_owner;

      if a_parse_time > l_cached_parse_time or l_cached_parse_time is null then

        update /*+ no_parallel */ &&ut3_owner..ut_suite_cache_schema t
           set t.parse_time = greatest(t.parse_time,a_parse_time)
         where object_owner = l_object_owner;

        if sql%rowcount = 0 then
          insert /*+ no_parallel */ into &&ut3_owner..ut_suite_cache_schema
            (object_owner, parse_time)
          values (l_object_owner, a_parse_time);
        end if;

        update  /*+ no_parallel */ &&ut3_owner..ut_suite_cache_package t
           set t.parse_time = a_parse_time
         where t.object_owner = l_object_owner
           and t.object_name = l_object_name;

        if sql%rowcount = 0 then
          insert /*+ no_parallel */ into &&ut3_owner..ut_suite_cache_package
            (object_owner, object_name, parse_time)
          values (l_object_owner, l_object_name, a_parse_time );
        end if;

        delete from &&ut3_owner..ut_suite_cache t
        where t.object_owner = l_object_owner
          and t.object_name  = l_object_name;

        insert /*+ no_parallel */ into &&ut3_owner..ut_suite_cache t
            (
                id, self_type, path, object_owner, object_name, name,
                line_no, parse_time, description,
                rollback_type, disabled_flag,disabled_reason, warnings,
                before_all_list, after_all_list,
                before_each_list, after_each_list,
                before_test_list, after_test_list,
                expected_error_codes, tags,
                item
            )
          with suites as (
               select treat(value(x) as &&ut3_owner..ut_suite) i
                 from table(a_suite_items) x
                where x.self_type in( 'UT_SUITE', 'UT_SUITE_CONTEXT' ) )
          select /*+ no_parallel */ &&ut3_owner..ut_suite_cache_seq.nextval, s.i.self_type as self_type, s.i.path as path,
                 upper(s.i.object_owner) as object_owner, upper(s.i.object_name) as object_name, upper(s.i.name) as name,
                 s.i.line_no as line_no, s.i.parse_time as parse_time, s.i.description as description,
                 s.i.rollback_type as rollback_type, s.i.disabled_flag as disabled_flag,s.i.disabled_reason as disabled_reason, s.i.warnings as warnings,
                 s.i.before_all_list as before_all_list, s.i.after_all_list as after_all_list,
                 null before_each_list, null after_each_list,
                 null before_test_list, null after_test_list,
                 null expected_error_codes, s.i.tags tags,
                 null item
          from suites s;

        insert /*+ no_parallel */ into &&ut3_owner..ut_suite_cache t
          (
            id, self_type, path, object_owner, object_name, name,
            line_no, parse_time, description,
            rollback_type, disabled_flag,disabled_reason, warnings,
            before_all_list, after_all_list,
            before_each_list, after_each_list,
            before_test_list, after_test_list,
            expected_error_codes, tags,
            item
          )
          with tests as (
               select treat(value(x) as &&ut3_owner..ut_test) t
                 from table ( a_suite_items ) x
                where x.self_type in ( 'UT_TEST' ) )
        select /*+ no_parallel */ &&ut3_owner..ut_suite_cache_seq.nextval, s.t.self_type as self_type, s.t.path as path,
               upper(s.t.object_owner) as object_owner, upper(s.t.object_name) as object_name, upper(s.t.name) as name,
               s.t.line_no as line_no, s.t.parse_time as parse_time, s.t.description as description,
               s.t.rollback_type as rollback_type, s.t.disabled_flag as disabled_flag, s.t.disabled_reason as disabled_reason, s.t.warnings as warnings,
               null before_all_list, null after_all_list,
               s.t.before_each_list as before_each_list, s.t.after_each_list as after_each_list,
               s.t.before_test_list as before_test_list, s.t.after_test_list as after_test_list,
               s.t.expected_error_codes as expected_error_codes, s.t.tags as test_tags,
               s.t.item as item
          from tests s;

      end if;
    end if;
    commit;
  end;

  procedure remove_missing_objs_from_cache(a_schema_name varchar2) is
    pragma autonomous_transaction;
  begin
    --rows of ut_suite_cache are removed by the "on delete cascade" foreign key
    delete /*+ no_parallel */ from &&ut3_owner..ut_suite_cache_package i
     where i.object_owner = a_schema_name
       and not exists (
             select 1
               from (&&ut3_owner..ut_annotation_cache_macros.get_cached_objects(a_schema_name, 'PACKAGE')) o
              where o.object_name = i.object_name
           );

    commit;
  end;

  function get_suite_items_info(
    a_suite_cache_items ut_suite_cache_rows
  ) return ut_suite_items_info is
    l_results      ut_suite_items_info;
  begin
    select /*+ no_parallel */ &&ut3_owner..ut_suite_item_info(
             c.object_owner, c.object_name, c.name,
             c.description, c.self_type, c.line_no,
             c.path, c.disabled_flag, c.disabled_reason, c.tags
             )
      bulk collect into l_results
      from table(a_suite_cache_items) c;
      return l_results;
  end;

  function get_cached_packages(
    a_schema_names ut_varchar2_rows
  ) return ut_object_names is
    l_results ut_object_names;
  begin
    select /*+ no_parallel */ &&ut3_owner..ut_object_name( c.object_owner, c.object_name )
      bulk collect into l_results
      from &&ut3_owner..ut_suite_cache_package c
      join table ( a_schema_names ) s
        on c.object_owner = upper(s.column_value);
    return l_results;
  end;

  function suite_item_exists(
    a_owner_name     varchar2,
    a_package_name   varchar2,
    a_procedure_name varchar2
  ) return boolean is
    l_count integer;
  begin
    if a_procedure_name is not null then
      select /*+ no_parallel */ count( 1 ) into l_count from dual
       where exists(
               select 1
                 from &&ut3_owner..ut_suite_cache c
                where c.object_owner = a_owner_name
                  and c.object_name = a_package_name
                  and c.name = a_procedure_name
               );
    elsif a_package_name is not null then
      select /*+ no_parallel */ count( 1 ) into l_count from dual
       where exists(
               select 1
                 from &&ut3_owner..ut_suite_cache c
                where c.object_owner = a_owner_name
                  and c.object_name = a_package_name
               );
    else
      select /*+ no_parallel */ count( 1 ) into l_count from dual
       where exists(
               select 1
                 from &&ut3_owner..ut_suite_cache c
                where c.object_owner = a_owner_name
               );
    end if;

    return l_count > 0;
  end;

end;
/
