create or replace package body ut_coverage_helper_block is
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

  procedure coverage_start(a_run_comment varchar2, a_coverage_id out integer)  is
  begin
    $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
      a_coverage_id := dbms_plsql_code_coverage.start_coverage(run_comment => a_run_comment);
    $else
      null;
    $end
  end;

  procedure coverage_stop is
  begin
    $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
      dbms_plsql_code_coverage.stop_coverage();
    $else
      null;
    $end
  end;

  function block_results(a_object_owner varchar2, a_object_name varchar2, a_coverage_id integer) return t_block_rows is
    l_coverage_rows t_block_rows;
  begin
          
    select ccb.line         as line,
           count(ccb.block) as blocks,
           sum(ccb.covered) as covered_blocks
      bulk collect into l_coverage_rows
      from dbmspcc_units ccu
      left outer join dbmspcc_blocks ccb
        on ccu.run_id = ccb.run_id
       and ccu.object_id = ccb.object_id
     where ccu.run_id = a_coverage_id
       and ccu.owner = a_object_owner
       and ccu.name = a_object_name
     group by ccb.line
     order by 1;
     
     return l_coverage_rows;
  end;

  function get_raw_coverage_data(a_object_owner varchar2, a_object_name varchar2, a_coverage_id integer) return ut_coverage_helper.t_unit_line_calls is
    l_tmp_data t_block_rows;
    l_results  ut_coverage_helper.t_unit_line_calls;
  
  begin
    $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
      l_tmp_data := block_results(a_object_owner, a_object_name, a_coverage_id);

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
    $end
    return l_results;
  end;
end;
/
