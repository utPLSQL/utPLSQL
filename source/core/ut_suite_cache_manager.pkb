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
  cursor c_get_bulk_cache_suite(cp_suite_items in ut_suite_cache_rows) is
    with  
      suite_items as (
        select  /*+ cardinality(c 500) */ value(c) as obj
          from table(cp_suite_items) c),
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
      )
      select /*+ no_parallel */ obj from suite_items
      union all
      select /*+ no_parallel */ obj from logical_suites;

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
        from schema_paths sp left outer join ut_suite_cache c
        on ( c.object_owner = upper(sp.schema_name)
        and c.object_name like  replace(upper(sp.object_name),'*','%'))
        where sp.suite_path is null and sp.object_name is not null
        and ( sp.procedure_name is null or sp.procedure_name = '*')
        group by sp.schema_name,nvl(c.object_name,sp.object_name)
      ),
      paths_for_procedures as (
      select /*+ no_parallel */ path as suite_path,sp.schema_name as schema_name,nvl(c.object_name,sp.object_name) as object_name,
        nvl(c.name,sp.procedure_name) as procedure_name
        from schema_paths sp left outer join ut_suite_cache c
        on ( c.object_owner = upper(sp.schema_name)
        and c.object_name like  replace(upper(sp.object_name),'*','%')
        and c.name like nvl(replace(upper(sp.procedure_name),'*','%'), c.name))
        where sp.suite_path is null and sp.object_name is not null
        and (sp.procedure_name is not null and sp.procedure_name != '*')      
      ),
      paths_for_suite_path_with_ast as (
      select /*+ no_parallel */ nvl(c.path,sp.suite_path) as suite_path,sp.schema_name,sp.object_name,sp.procedure_name as procedure_name
        from schema_paths sp left outer join ut_suite_cache c on
        ( c.object_owner = upper(sp.schema_name) 
        --and c.path like replace(sp.suite_path,'*','%'))
        and regexp_like(c.path,'^'||replace(sp.suite_path,'*','[A-Za-z0-9$#_]*')))
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
    select ut_path_item(schema_name,object_name,procedure_name,suite_path)
      bulk collect into l_schema_paths
      from 
      (select schema_name,object_name,procedure_name,suite_path,
      row_number() over ( partition by schema_name,object_name,procedure_name,suite_path order by 1) as r_num
      from all_suitepaths_together)
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
    select  /*+ cardinality(c 500) */ value(c) as obj,row_number() over ( partition by path,object_owner order by path,object_owner asc) as r_num  
      from ut_suite_cache c,
      table(a_schema_paths)  sp
      where c.object_owner = upper(sp.schema_name)
      and ((sp.suite_path is not null and sp.suite_path||'.' like  c.path||'.%' /*all parents and self*/               
        or
        ( 
          c.path||'.' like sp.suite_path||'.%'	/*all children and self*/
          and c.object_name like nvl(upper(sp.object_name),c.object_name)						 
          and c.name like nvl(upper(sp.procedure_name),c.name) 
        ))          
        or
        ( sp.suite_path is null
        and c.object_name = nvl(upper(sp.object_name),c.object_name)					 
        and c.name = nvl(upper(sp.procedure_name),c.name)))) where r_num =1;        
    return l_suite_items;
  end;
  
  /*
    To support a legact tag notation 
    , = OR
    - = NOT
    we will perform a replace of that characters into
    new notation.
    || = OR
    && = AND
    ^  = NOT
  */
  --TODO: How do we prevent when old notation reach 4k an new will be longer?
  function replace_legacy_tag_notation(a_tags varchar2
  ) return varchar2 is
    l_tags ut_varchar2_list := ut_utils.string_to_table(a_tags,',');
    l_tags_include varchar2(2000);
    l_tags_exclude varchar2(2000);
    l_return_tag varchar2(4000);
  begin
    select listagg( t.column_value,' | ')
      within group( order by column_value) 
    into l_tags_include
    from table(l_tags) t
    where t.column_value not like '-%';
    
    select listagg( replace(t.column_value,'-','!'),' & ')
      within group( order by column_value) 
    into l_tags_exclude
    from table(l_tags) t
    where t.column_value like '-%';   
    
    l_return_tag:= 
    case when l_tags_include is not null then 
      '('||l_tags_include||')' else null end  ||
    case when l_tags_include is not null and l_tags_exclude is not null then
    ' & ' else null end ||
    case when l_tags_exclude is not null then 
    '('||l_tags_exclude||')' else null end;
      
    return l_return_tag;
  end;
    
  function create_where_filter(a_tags varchar2
  ) return varchar2 is
    l_tags varchar2(4000):= replace(a_tags,' ');
  begin
    if instr(l_tags,',') > 0 or instr(l_tags,'-') > 0 then
      l_tags := replace(replace_legacy_tag_notation(l_tags),' ');
    end if;
    l_tags := REGEXP_REPLACE(l_tags, 
                      '(\(|\)|\||\!|\&)?([^|&!-()]+)(\(|\)|\||\!|\&)?', 
                      q'[\1q'<\2>' member of tags\3]');    
    --replace operands to XPath
    l_tags := REPLACE(l_tags, '|',' or ');
    l_tags := REPLACE(l_tags , '&',' and ');
    l_tags := REGEXP_REPLACE(l_tags,q'[(\!)(q'<[^|&!]+?>')( member of tags)]','\2 not \3');
    l_tags := '('||l_tags||')';
    return l_tags;       
  end;  
  
  /*
    Having a base set of suites we will do a further filter down if there are
    any tags defined.
  */      
  function get_tags_suites (
    a_suite_items ut_suite_cache_rows,
    a_tags varchar2
  ) return ut_suite_cache_rows is
    l_suite_tags      ut_suite_cache_rows := ut_suite_cache_rows();  
    l_sql varchar2(32000);
    l_tags varchar2(4000):= create_where_filter(a_tags);
  begin
    l_sql :=
    q'[
with 
  suites_mv as (
    select c.id,value(c) as obj,c.path as path,c.self_type,c.object_owner,c.tags
    from table(:suite_items) c
  ),
  suites_matching_expr as (
    select c.id,c.path as path,c.self_type,c.object_owner,c.tags
    from suites_mv c
    where c.self_type in ('UT_SUITE','UT_CONTEXT')
    and ]'||l_tags||q'[
  ),
  tests_matching_expr as (
    select c.id,c.path as path,c.self_type,c.object_owner,c.tags
    from suites_mv c where c.self_type in ('UT_TEST')
    and ]'||l_tags||q'[
  ),  
  tests_with_tags_inh_from_suite as (
   select c.id,c.self_type,c.path,c.tags multiset union distinct t.tags tags,c.object_owner
   from suites_mv c join suites_matching_expr t 
     on (c.path||'.' like t.path || '.%' /*all descendants and self*/ and c.object_owner = t.object_owner)
  ),
  tests_with_tags_prom_to_suite as (
    select c.id,c.self_type,c.path,c.tags multiset union distinct t.tags tags,c.object_owner
    from suites_mv c join tests_matching_expr t 
      on (t.path||'.' like c.path || '.%' /*all ancestors and self*/ and c.object_owner = t.object_owner)
  )
  select obj from suites_mv c,
    (select id,row_number() over (partition by id order by id) r_num from
      (select id
      from tests_with_tags_prom_to_suite tst
      where ]'||l_tags||q'[        
      union all
      select id from tests_with_tags_inh_from_suite tst
      where ]'||l_tags||q'[   
      )
    ) t where c.id = t.id and r_num = 1 ]';
    
    execute immediate l_sql bulk collect into  l_suite_tags using a_suite_items;   
    return l_suite_tags;        
  end;
  
  /*
    We will sort a suites in hierarchical structure.
    Sorting from bottom to top so when we consolidate
    we will go in proper order.
    For random seed we will add an extra sort that can be null.
    The object owner is irrelevant on joing via path as we already
    resolved a list of test we want to use so as long they share a suitepath
    they are correct.
  */
  procedure sort_and_randomize_tests(
    a_suite_rows in out ut_suite_cache_rows,
    a_random_seed  positive := null) 
  is
    l_suite_rows ut_suite_cache_rows;
  begin
    with
    extract_parent_child as (
        select s.path, substr(s.path,1,instr(s.path,'.',-1,1)-1) as parent_path,s.object_owner,
          case when a_random_seed is null then s.line_no end line_no,
          case when a_random_seed is not null then ut_utils.hash_suite_path(s.path, a_random_seed) end random_seed
          from table(a_suite_rows) s),        
      t1(path,parent_path,object_owner,line_no,random_seed) as (
        --Anchor member
        select s.path, parent_path,s.object_owner,s.line_no,random_seed
          from extract_parent_child s
          where parent_path is null
        union all
        --Recursive member
        select t2.path, t2.parent_path,t2.object_owner,t2.line_no,t2.random_seed
          from t1,extract_parent_child t2
          where t2.parent_path = t1.path
           and t2.object_owner = t1.object_owner)
      search depth first by line_no desc,random_seed desc nulls last set order1
      select  value(i) as obj  
        bulk collect into l_suite_rows 
        from t1 c
        join table(a_suite_rows) i on i.object_owner = c.object_owner and i.path = c.path
        order by order1 desc;      
        
    a_suite_rows := l_suite_rows;
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
    a_tags             varchar2 := null
  ) return ut_suite_cache_rows is
    l_results         ut_suite_cache_rows := ut_suite_cache_rows();
    l_suite_items     ut_suite_cache_rows := ut_suite_cache_rows();
    l_schema_paths    ut_path_items;
    l_tags            varchar2(4000) := a_tags;
  begin     

    l_schema_paths := a_schema_paths;
    l_suite_items := get_suite_items(a_schema_paths);
    if length(l_tags) > 0 then
      l_suite_items := get_tags_suites(l_suite_items,l_tags);
    end if;
    
    open c_get_bulk_cache_suite(l_suite_items);
    fetch c_get_bulk_cache_suite bulk collect into l_results;
    close c_get_bulk_cache_suite;
      
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
           set t.parse_time = greatest(t.parse_time,a_parse_time)
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
