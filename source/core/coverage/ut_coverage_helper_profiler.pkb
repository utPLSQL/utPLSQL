create or replace package body ut_coverage_helper_profiler is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

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


  function coverage_start(a_run_comment varchar2) return integer is
    l_coverage_id integer;
  begin
    dbms_profiler.start_profiler(run_comment => a_run_comment, run_number => l_coverage_id);
    return l_coverage_id;
  end;

  procedure coverage_pause is
    l_return_code binary_integer;
  begin
    l_return_code := dbms_profiler.pause_profiler();
  end;

  procedure coverage_resume is
    l_return_code binary_integer;
  begin
    l_return_code := dbms_profiler.resume_profiler();
  end;

  procedure coverage_stop is
  begin
   dbms_profiler.stop_profiler();
  end;

  function proftab_results(a_object ut_coverage_helper.t_tmp_table_object, a_coverage_run_id raw) return t_proftab_rows is
    l_coverage_rows t_proftab_rows;
  begin
    select /*+ no_parallel */
        d.line#,
        case when sum(d.total_occur) = 0 and sum(d.total_time) > 0 then 1 else sum(d.total_occur) end total_occur
      bulk collect into l_coverage_rows
      from plsql_profiler_units u
      join plsql_profiler_data d
        on u.runid = d.runid
       and u.unit_number = d.unit_number
      join ut_coverage_runs r
        on r.line_coverage_id = u.runid
     where r.coverage_run_id = a_coverage_run_id
       and u.unit_owner = a_object.owner
       and u.unit_name = a_object.name
       and u.unit_type = a_object.type
     group by d.line#;

    return l_coverage_rows;
  end;
  
  function get_raw_coverage_data(a_object ut_coverage_helper.t_tmp_table_object, a_coverage_run_id raw) return ut_coverage_helper.t_unit_line_calls is
    l_tmp_data t_proftab_rows;
    l_results  ut_coverage_helper.t_unit_line_calls;  
  begin
    l_tmp_data := proftab_results(a_object, a_coverage_run_id);
       
    for i in 1 .. l_tmp_data.count loop
      l_results(l_tmp_data(i).line).calls := l_tmp_data(i).calls;
    end loop;
    return l_results;
  end;

end;
/
