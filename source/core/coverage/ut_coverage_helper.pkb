create or replace package body ut_coverage_helper is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2017 utPLSQL Project

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

  g_coverage_id  integer;
  g_develop_mode boolean not null := false;
  g_is_started   boolean not null := false;


  type t_proftab_row is record (
      line  binary_integer,
      calls number(38,0)
    );
    
  type t_proftab_rows is table of t_proftab_row;

  type t_block_row is record(
       line           binary_integer
      ,blocks         binary_integer
      ,covered_blocks binary_integer);
  
  type t_block_rows is table of t_block_row;

  procedure set_coverage_type(a_coverage_type in varchar2) is
  begin
    g_coverage_type := a_coverage_type;
  end;

  function get_coverage_type return varchar2 is
  begin
    return g_coverage_type;
  end;

  function is_develop_mode return boolean is
  begin
    return g_develop_mode;
  end;

  procedure coverage_start_internal(a_run_comment varchar2,a_coverage_type in varchar2)  is
  l_start_block varchar2(32767):= 'call dbms_plsql_code_coverage.start_coverage(run_comment => :a_run_comment)
                                   into :g_coverage_id';
  begin
    set_coverage_type(a_coverage_type);
    -- Make it dynamic to allow for block coverage.
    if get_coverage_type = 'block' then
       execute immediate l_start_block USING IN a_run_comment, OUT g_coverage_id;
       --g_coverage_id := dbms_plsql_code_coverage.start_coverage(run_comment => a_run_comment);
    else
       dbms_profiler.start_profiler(run_comment => a_run_comment, run_number => g_coverage_id);
       coverage_pause();
    end if;
    g_is_started := true;
  end;

  procedure coverage_start(a_run_comment varchar2,a_coverage_type in varchar2) is
  begin
    if not g_is_started then
      g_develop_mode := false;
      coverage_start_internal(a_run_comment,a_coverage_type);
    end if;
  end;

  procedure coverage_start_develop(a_coverage_type in varchar2) is
  begin
    if not g_is_started then
      g_develop_mode := true;
      coverage_start_internal('utPLSQL Code coverage run in development MODE '||ut_utils.to_string(systimestamp),a_coverage_type);
    end if;
  end;

  procedure coverage_pause is
    l_return_code binary_integer;
  begin
    if not g_develop_mode then
      if get_coverage_type = 'block' then
         null;
      else
         l_return_code := dbms_profiler.pause_profiler();
      end if;
    end if;
  end;

  procedure coverage_resume is
    l_return_code binary_integer;
  begin
    if get_coverage_type = 'block' then
       null;
    else
       l_return_code := dbms_profiler.resume_profiler();
    end if;
  end;

  procedure coverage_stop is
  l_stop_block varchar2(100) := 'call dbms_plsql_code_coverage.stop_coverage()';
  begin
    if not g_develop_mode then
      g_is_started := false;
      if get_coverage_type = 'block' then
         execute immediate l_stop_block;
      else
         dbms_profiler.stop_profiler();
      end if;
    end if;
  end;

  procedure coverage_stop_develop is
  begin
    g_develop_mode := false;
    g_is_started := false;
    if get_coverage_type = 'block' then
       null;
    else
       dbms_profiler.stop_profiler();
   end if;
  end;

  function proftab_results(a_object_owner varchar2, a_object_name varchar2) return t_proftab_rows is
   c_raw_coverage sys_refcursor;
   l_coverage_rows t_proftab_rows;
  begin
     open c_raw_coverage for q'[select d.line#,
        case when sum(d.total_occur) = 0 and sum(d.total_time) > 0 then 1 else sum(d.total_occur) end total_occur
        from plsql_profiler_units u
        join plsql_profiler_data d
          on u.runid = d.runid
         and u.unit_number = d.unit_number
       where u.runid = :g_coverage_id
         and u.unit_owner = :a_object_owner
         and u.unit_name = :a_object_name
         and u.unit_type not in ('PACKAGE SPEC', 'TYPE SPEC', 'ANONYMOUS BLOCK')
       group by d.line#]' using g_coverage_id,a_object_owner,a_object_name;
       
      FETCH c_raw_coverage BULK COLLECT
         INTO l_coverage_rows;
      CLOSE c_raw_coverage;

      RETURN l_coverage_rows; 
  end;
  
  function get_raw_coverage_data_profiler(a_object_owner varchar2, a_object_name varchar2) return t_unit_line_calls is
    l_tmp_data t_proftab_rows;
    l_results  t_unit_line_calls;  
  begin
    l_tmp_data := proftab_results(a_object_owner => a_object_owner, a_object_name => a_object_name);
       
    for i in 1 .. l_tmp_data.count loop
      l_results(l_tmp_data(i).line).calls := l_tmp_data(i).calls;
    end loop;
    return l_results;
  end;

  function block_results(a_object_owner varchar2, a_object_name varchar2) return t_block_rows is
   c_raw_coverage sys_refcursor;
   l_coverage_rows t_block_rows;
  begin
     open c_raw_coverage for q'[select ccb.line
          ,count(ccb.block) totalblocks
          ,sum(ccb.covered) 
      from dbmspcc_units ccu
      left outer join dbmspcc_blocks ccb
        on ccu.run_id = ccb.run_id
       and ccu.object_id = ccb.object_id
     where ccu.run_id = :g_coverage_id
       and ccu.owner = :a_object_owner
       and ccu.name = :a_object_name
     group by ccb.line
     order by 1]' using g_coverage_id,a_object_owner,a_object_name;
       
     fetch c_raw_coverage bulk collect into l_coverage_rows;
     close c_raw_coverage;
      
     return l_coverage_rows; 
  end;

  function get_raw_coverage_data_block(a_object_owner varchar2, a_object_name varchar2) return t_unit_line_calls is
    l_tmp_data t_block_rows;
    l_results  t_unit_line_calls;
  
  begin
    l_tmp_data := block_results(a_object_owner => a_object_owner, a_object_name => a_object_name);
    for i in 1 .. l_tmp_data.count loop
      l_results(l_tmp_data(i).line).blocks := l_tmp_data(i).blocks;
      l_results(l_tmp_data(i).line).covered_blocks := l_tmp_data(i).covered_blocks;
      l_results(l_tmp_data(i).line).partcovered := case
                                                     when (l_tmp_data(i).covered_blocks > 0) and
                                                          (l_tmp_data(i).blocks > l_tmp_data(i).covered_blocks) then
                                                      1
                                                     else
                                                      0
                                                   end;
    end loop;
    return l_results;
  end;

  procedure mock_coverage_id(a_coverage_id integer) is
  begin
    g_develop_mode := true;
    g_is_started := true;
    g_coverage_id := a_coverage_id;
  end;

  procedure insert_into_tmp_table(a_data t_coverage_sources_tmp_rows) is
  begin
    forall i in 1 .. a_data.count
      insert into ut_coverage_sources_tmp
             (full_name,owner,name,line,text, to_be_skipped)
       values(a_data(i).full_name,a_data(i).owner,a_data(i).name,a_data(i).line,a_data(i).text,a_data(i).to_be_skipped);
  end;

  procedure cleanup_tmp_table is
    pragma autonomous_transaction;
  begin
    null;
    execute immediate 'truncate table ut_coverage_sources_tmp$';
    commit;
  end;

  function is_tmp_table_populated return boolean is
    l_result integer;
  begin
    select 1 into l_result from ut_coverage_sources_tmp where rownum = 1;
    return (l_result = 1);
  exception
    when no_data_found then
      return false;
  end;

  function get_tmp_table_objects_cursor return t_tmp_table_objects_crsr is
    l_result t_tmp_table_objects_crsr;
  begin
    open l_result for
      select o.owner, o.name, o.full_name, max(o.line) lines_count,
             cast(
               collect(decode(to_be_skipped, 'Y', to_char(line))) as ut_varchar2_list
             ) to_be_skipped_list
        from ut_coverage_sources_tmp o
       group by o.owner, o.name, o.full_name;

    return l_result;
  end;

  function get_tmp_table_object_lines(a_owner varchar2, a_object_name varchar2) return ut_varchar2_list is
    l_result ut_varchar2_list;
  begin
    select rtrim(s.text,chr(10)) text
      bulk collect into l_result
      from ut_coverage_sources_tmp s
     where s.owner = a_owner
       and s.name = a_object_name
     order by s.line;

    return l_result;
  end;

end;
/
