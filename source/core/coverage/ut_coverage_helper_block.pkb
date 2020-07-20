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

  type t_block_row is record(
       line           binary_integer
      ,blocks         binary_integer
      ,covered_blocks binary_integer);
  
  type t_block_rows is table of t_block_row;

  function coverage_start(a_run_comment varchar2) return integer is
  begin
    $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
      return dbms_plsql_code_coverage.start_coverage(run_comment => a_run_comment);
    $else
      return null;
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

  function block_results(a_object ut_coverage_helper.t_tmp_table_object, a_coverage_run_id raw) return t_block_rows is
    l_coverage_rows t_block_rows;
    l_ut_owner       varchar2(250) := ut_utils.ut_owner;
  begin
    execute immediate q'[
    select line         as line,
           count(block) as blocks,
           sum(covered) as covered_blocks
    from (select line,
                 block,
                 max(covered) as covered
            from dbmspcc_units ccu
            join ]'||l_ut_owner||q'[.ut_coverage_runs r
              on r.block_coverage_id = ccu.run_id
            left join dbmspcc_blocks ccb
              on ccu.run_id = ccb.run_id
             and ccu.object_id = ccb.object_id
           where r.coverage_run_id = :a_coverage_run_id
             and ccu.owner = :a_object_owner
             and ccu.name = :a_object_name
             and ccu.type = :a_object_type
           group by ccb.line, ccb.block
         )
     group by line
     having count(block) > 1
     order by line]'
    bulk collect into l_coverage_rows
    using
      a_coverage_run_id, a_object.owner,
      a_object.name, a_object.type;

    return l_coverage_rows;
  end;

  function get_raw_coverage_data(a_object ut_coverage_helper.t_tmp_table_object, a_coverage_run_id raw) return ut_coverage_helper.t_unit_line_calls is
    l_tmp_data t_block_rows;
    l_results  ut_coverage_helper.t_unit_line_calls;
  
  begin
    $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
      l_tmp_data := block_results(a_object, a_coverage_run_id);

      for i in 1 .. l_tmp_data.count loop
        l_results(l_tmp_data(i).line).blocks := l_tmp_data(i).blocks;
        l_results(l_tmp_data(i).line).covered_blocks := l_tmp_data(i).covered_blocks;
        l_results(l_tmp_data(i).line).partcovered :=
          case
            when (l_tmp_data(i).covered_blocks > 0)
             and (l_tmp_data(i).blocks > l_tmp_data(i).covered_blocks)
            then 1
            else 0
         end;
      end loop;
    $end
    return l_results;
  end;
end;
/
