create or replace package body ut_suite_cache_manager is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
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

  gc_get_bulk_cache_suite_sql    constant varchar2(32767) :=
    q'[with  
      suite_items as (
        select  /*+ cardinality(c 500) */ value(c) as obj
          from table(:suite_items) c),
      suitepaths as (
        select distinct substr(c.obj.path,1,instr(c.obj.path,'.',-1)-1) as suitepath,
                        c.obj.path as path,
                        c.obj.object_owner as object_owner
          from suite_items c
         where c.obj.self_type = 'UT_SUITE'
      ),
        gen as (
        select rownum as pos
          from xmltable('1 to 20')
      ),
      suitepath_part AS (
        select distinct
                        substr(b.suitepath, 1, instr(b.suitepath || '.', '.', 1, g.pos) -1) as path,
                        object_owner
          from suitepaths b
               join gen g
                 on g.pos <= regexp_count(b.suitepath, '\w+')
      ),
      logical_suite_data as (
        select 'UT_LOGICAL_SUITE' as self_type, p.path, p.object_owner,
               upper( substr(p.path, instr( p.path, '.', -1 ) + 1 ) ) as object_name,
               cast(null as ut_executables) as x,
               cast(null as ut_varchar2_rows) as y,
               cast(null as ut_executable_test) as z
          from suitepath_part p
         where p.path
           not in (select s.path from suitepaths s)
      ),
      logical_suites as (
        select ut_suite_cache_row(
                 null,
                 s.self_type, s.path, s.object_owner, s.object_name,
                 s.object_name, null, null, null, null, 0,null,
                 ut_varchar2_rows(),
                 s.x, s.x, s.x, s.x, s.x, s.x,
                 s.y, null, s.z
               ) as obj
          from logical_suite_data s
      ),
      items as (
        select obj from suite_items
        union all
        select obj from logical_suites
      )
    select /*+ no_parallel */ c.obj
      from items c
     order by c.obj.object_owner,{:random_seed:}]';

  function get_missing_cache_objects(a_object_owner varchar2) return ut_varchar2_rows is
    l_result       ut_varchar2_rows;
    l_data         ut_annotation_objs_cache_info;
  begin
    l_data := ut_annotation_cache_manager.get_cached_objects_list(a_object_owner, 'PACKAGE');

    select /*+ no_parallel */ i.object_name
           bulk collect into l_result
      from ut_suite_cache_package i
     where not exists (
       select 1 from table(l_data) o
        where o.object_owner = i.object_owner
          and o.object_name = i.object_name
          and o.object_type = 'PACKAGE'
       )
       and i.object_owner = a_object_owner;
    return l_result;
  end;

  function get_random_seed_sql(a_random_seed positive) return varchar2 is
  begin
    return case
           when a_random_seed is null then q'[
              nlssort(
                replace(
                  /*suite path until objects name (excluding contexts and test path) with trailing dot (full stop)*/
                  substr( c.obj.path, 1, instr( c.obj.path, lower(c.obj.object_name), -1 ) + length(c.obj.object_name) ),
                  '.',
                  /*'.' replaced with chr(0) to assure that child elements come before parent when sorting in descending order*/
                  chr(0)
                ),
                'nls_sort=binary'
              )desc nulls last,
              case when c.obj.self_type = 'UT_SUITE_CONTEXT' then
                ( select /*+ no_parallel */ max( x.line_no ) + 1
                    from ut_suite_cache x
                   where c.obj.object_owner = x.object_owner
                     and c.obj.object_name = x.object_name
                     and x.path like c.obj.path || '.%'
                )
              else
                c.obj.line_no
              end,
              /*assures that child contexts come before parent contexts*/
              regexp_count(c.obj.path,'\.') desc,
              :a_random_seed]'
           else
             ' ut_runner.hash_suite_path(
               c.obj.path, :a_random_seed
             ) desc nulls last'
           end;
  end;
  
  function group_paths_by_schema(a_paths ut_varchar2_list) return ut_path_items is
    c_package_path_regex constant varchar2(100) := '^([A-Za-z0-9$#_]+)(\.([A-Za-z0-9$#_\*]+))?(\.([A-Za-z0-9$#_\*]+))?$';
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
    The object name is populate but suitepath not 
    We will use that object and try to match.
    We can pass also a wildcard this will result in one to many.
    
    Get all data that do not have an wildcard and not require expanding.
    We will take them as they are.
      a)suite path is populated 
      b)suite path and object is empty so schema name is by default ( or passed)
  */   
  function expand_paths(a_schema_paths ut_path_items) return ut_path_items is
    l_schema_paths ut_path_items:= ut_path_items();
  begin   
    with paths_to_expand as ( 
      select /*+ no_parallel */ min(path) as suite_path,sp.schema_name as schema_name,nvl(c.object_name,sp.object_name) as object_name,
        nvl2(sp.procedure_name,c.name,null) as procedure_name
        from table(a_schema_paths) sp left outer join ut_suite_cache c
        on ( c.object_owner = upper(sp.schema_name)
        and c.object_name like  replace(upper(sp.object_name),'*','%')
        and c.name like nvl(replace(upper(sp.procedure_name),'*','%'), c.name))
        where sp.suite_path is null and sp.object_name is not null
        group by sp.schema_name,nvl(c.object_name,sp.object_name),nvl2(sp.procedure_name,c.name,null)
      union all
      select /*+ no_parallel */ nvl(c.path,sp.suite_path) as suite_path,sp.schema_name,sp.object_name,sp.procedure_name as procedure_name
        from
        table(a_schema_paths) sp left outer join ut_suite_cache c on
        ( c.object_owner = upper(sp.schema_name) 
        and c.path like replace(sp.suite_path,'*','%'))       
        where sp.suite_path is not null and instr(sp.suite_path,'*') > 0
      union all
      select /*+ no_parallel */ sp.suite_path as suite_path,sp.schema_name,sp.object_name,sp.procedure_name as procedure_name
       from table(a_schema_paths) sp
       where 
       (sp.suite_path is not null and instr(sp.suite_path,'*') = 0)
       or 
       (sp.suite_path is null and sp.object_name is null)
    )
    select ut_path_item(schema_name,object_name,procedure_name,suite_path)
      bulk collect into l_schema_paths
      from 
      (select schema_name,object_name,procedure_name,suite_path,
      row_number() over ( partition by schema_name,object_name,procedure_name,suite_path order by 1) as r_num
      from paths_to_expand)
      where r_num = 1 ;
    return l_schema_paths;
  end;
  
  /*
    Get a suite items rows that matching our criteria like
    path,object_name etc.
    We need to consider also an wildcard character on our procedures and object
    names.
    Were the path is populated we need to make sure we dont return duplicates
    as the wildcard can produce multiple results from same path and 
    parents and child for each can be same resulting in duplicates    
  */  
  function get_suite_items (
    a_schema_paths ut_path_items
  ) return ut_suite_cache_rows is
    l_suite_items ut_suite_cache_rows := ut_suite_cache_rows();
  begin
    select obj bulk collect into  l_suite_items
    from (
    select  /*+ cardinality(c 500) */ value(c) as obj,row_number() over ( partition by path order by path asc) as r_num  
      from ut_suite_cache c,
      table(a_schema_paths)  sp
      where c.object_owner = upper(sp.schema_name)
      and ( 
        (sp.suite_path is not null and
        sp.suite_path||'.' like  c.path||'.%' /*all parents and self*/               
      or
        ( c.path||'.' like sp.suite_path||'.%'	/*all children and self*/
        and c.object_name like nvl(upper(sp.object_name),c.object_name)						 
        and c.name like nvl(upper(sp.procedure_name),c.name) ) )          
        or
        ( sp.suite_path is null
        and c.object_name like nvl(upper(replace(sp.object_name,'*','%')),c.object_name)					 
        and c.name like nvl(upper(replace(sp.procedure_name,'*','%')),c.name)
         ))) where r_num = 1;           
    return l_suite_items;
  end;
  
  /*
    Having a base set of suites we will do a further filter down if there are
    any tags defined.
  */    
  function get_tags_suites (
    a_suite_items ut_suite_cache_rows,
    a_tags ut_varchar2_rows
  ) return ut_suite_cache_rows is
    l_suite_tags ut_suite_cache_rows := ut_suite_cache_rows();
    l_include_tags    ut_varchar2_rows;
    l_exclude_tags    ut_varchar2_rows;    
  begin

    select /*+ no_parallel */ column_value
      bulk collect into l_include_tags
      from table(a_tags)
     where column_value not like '-%';

    select /*+ no_parallel */ ltrim(column_value,'-')
      bulk collect into l_exclude_tags
      from table(a_tags)
     where column_value like '-%';  
  
    with included_tags as (
        select c.path as path
          from table(a_suite_items) c
         where c.tags multiset intersect l_include_tags is not empty or l_include_tags is empty
       ),
       excluded_tags as (
        select c.path as path
          from table(a_suite_items) c
         where c.tags multiset intersect l_exclude_tags is not empty
       )
       select value(c) as obj
       bulk collect into  l_suite_tags
         from table(a_suite_items) c
        where exists (
          select 1 from included_tags t
           where t.path||'.' like c.path || '.%' /*all parents and self*/
              or c.path||'.' like t.path || '.%' /*all children and self*/
          )
        and not exists (
          select 1 from excluded_tags t
           where c.path||'.' like t.path || '.%' /*all children and self*/
          );
    return l_suite_tags;      
  end;
  
  /*
  * Public code
  */
  
  function get_schema_paths(a_paths in ut_varchar2_list) return ut_path_items is
  begin
    return expand_paths(group_paths_by_schema(a_paths));
  end;
  
  function get_cached_suite_rows(
    a_schema_paths     ut_path_items,
    a_random_seed      positive := null,
    a_tags             ut_varchar2_rows := null
  ) return ut_suite_cache_rows is
    l_results         ut_suite_cache_rows := ut_suite_cache_rows();
    l_suite_items     ut_suite_cache_rows := ut_suite_cache_rows();
    l_schema_paths    ut_path_items;
    l_tags            ut_varchar2_rows := coalesce(a_tags,ut_varchar2_rows());
    l_sql             varchar2(32767);
  begin     

    l_schema_paths := a_schema_paths;
    l_sql := gc_get_bulk_cache_suite_sql;
    l_sql := replace(l_sql,'{:random_seed:}',get_random_seed_sql(a_random_seed));
    l_suite_items := get_suite_items(a_schema_paths);
    if l_tags.count > 0 then
      l_suite_items := get_tags_suites(l_suite_items,l_tags);
    end if;
    ut_event_manager.trigger_event(ut_event_manager.gc_debug, ut_key_anyvalues().put('l_sql',l_sql) );
       
    execute immediate l_sql
      bulk collect into l_results
      using l_suite_items, a_random_seed;
    return l_results;
  end;
    
  

  function get_schema_parse_time(a_schema_name varchar2) return timestamp result_cache is
    l_cache_parse_time timestamp;
  begin
    select /*+ no_parallel */ min(t.parse_time)
      into l_cache_parse_time
      from ut_suite_cache_schema t
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
    if a_suite_items is not null and a_suite_items.count = 0 then

      delete from ut_suite_cache t
       where t.object_owner = l_object_owner
         and t.object_name = l_object_name;

      delete from ut_suite_cache_package t
       where t.object_owner = l_object_owner
         and t.object_name = l_object_name;

    else

      select /*+ no_parallel */ min(parse_time)
        into l_cached_parse_time
        from ut_suite_cache_package t
       where t.object_name = l_object_name
         and t.object_owner = l_object_owner;

      if a_parse_time > l_cached_parse_time or l_cached_parse_time is null then

        update /*+ no_parallel */ ut_suite_cache_schema t
           set t.parse_time = a_parse_time
         where object_owner = l_object_owner;

        if sql%rowcount = 0 then
          insert /*+ no_parallel */ into ut_suite_cache_schema
            (object_owner, parse_time)
          values (l_object_owner, a_parse_time);
        end if;

        update  /*+ no_parallel */ ut_suite_cache_package t
           set t.parse_time = a_parse_time
         where t.object_owner = l_object_owner
           and t.object_name = l_object_name;

        if sql%rowcount = 0 then
          insert /*+ no_parallel */ into ut_suite_cache_package
            (object_owner, object_name, parse_time)
          values (l_object_owner, l_object_name, a_parse_time );
        end if;

        delete from ut_suite_cache t
        where t.object_owner = l_object_owner
          and t.object_name  = l_object_name;

        insert /*+ no_parallel */ into ut_suite_cache t
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
               select treat(value(x) as ut_suite) i
                 from table(a_suite_items) x
                where x.self_type in( 'UT_SUITE', 'UT_SUITE_CONTEXT' ) )
          select /*+ no_parallel */ ut_suite_cache_seq.nextval, s.i.self_type as self_type, s.i.path as path,
                 upper(s.i.object_owner) as object_owner, upper(s.i.object_name) as object_name, upper(s.i.name) as name,
                 s.i.line_no as line_no, s.i.parse_time as parse_time, s.i.description as description,
                 s.i.rollback_type as rollback_type, s.i.disabled_flag as disabled_flag,s.i.disabled_reason as disabled_reason, s.i.warnings as warnings,
                 s.i.before_all_list as before_all_list, s.i.after_all_list as after_all_list,
                 null before_each_list, null after_each_list,
                 null before_test_list, null after_test_list,
                 null expected_error_codes, s.i.tags tags,
                 null item
          from suites s;

        insert /*+ no_parallel */ into ut_suite_cache t
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
               select treat(value(x) as ut_test) t
                 from table ( a_suite_items ) x
                where x.self_type in ( 'UT_TEST' ) )
        select /*+ no_parallel */ ut_suite_cache_seq.nextval, s.t.self_type as self_type, s.t.path as path,
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
    l_objects ut_varchar2_rows;
    pragma autonomous_transaction;
  begin
    l_objects := get_missing_cache_objects(a_schema_name);

    if l_objects is not empty then
      delete /*+ no_parallel */ from ut_suite_cache i
       where i.object_owner = a_schema_name
         and i.object_name in ( select /*+ no_parallel */ column_value from table (l_objects) );

      delete /*+ no_parallel */ from ut_suite_cache_package i
       where i.object_owner = a_schema_name
         and i.object_name in ( select /*+ no_parallel */ column_value from table (l_objects) );
    end if;

    commit;
  end;

  function get_cached_suite_info(
    a_schema_paths     ut_path_items
  ) return ut_suite_cache_rows is
  begin
    return get_cached_suite_rows( a_schema_paths );
  end;

  function get_suite_items_info(
    a_suite_cache_items ut_suite_cache_rows
  ) return ut_suite_items_info is
    l_results      ut_suite_items_info;
  begin
    select /*+ no_parallel */ ut_suite_item_info(
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
    select /*+ no_parallel */ ut_object_name( c.object_owner, c.object_name )
      bulk collect into l_results
      from ut_suite_cache_package c
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
                 from ut_suite_cache c
                where c.object_owner = a_owner_name
                  and c.object_name = a_package_name
                  and c.name = a_procedure_name
               );
    elsif a_package_name is not null then
      select /*+ no_parallel */ count( 1 ) into l_count from dual
       where exists(
               select 1
                 from ut_suite_cache c
                where c.object_owner = a_owner_name
                  and c.object_name = a_package_name
               );
    else
      select /*+ no_parallel */ count( 1 ) into l_count from dual
       where exists(
               select 1
                 from ut_suite_cache c
                where c.object_owner = a_owner_name
               );
    end if;

    return l_count > 0;
  end;

end;
/
