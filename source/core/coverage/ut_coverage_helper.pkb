create or replace package body ut_coverage_helper is
  /*
  utPLSQL - Version X.X.X.X
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

  g_coverage_id integer;
  g_develop_mode boolean;

  function  is_develop_mode return boolean is
  begin
    return g_develop_mode;
  end;

  procedure coverage_start_internal(a_run_comment varchar2)  is
  begin
    dbms_profiler.start_profiler(run_comment => a_run_comment, run_number => g_coverage_id);
    coverage_pause();
  end;

  procedure coverage_start(a_run_comment varchar2) is
  begin
    if g_develop_mode is null then
      g_develop_mode := false;
      coverage_start_internal(a_run_comment);
    end if;
  end;

  procedure coverage_start_develop is
  begin
    g_develop_mode := true;
    coverage_start_internal('utPLSQL Code coverage run in development MODE '||ut_utils.to_string(systimestamp));
  end;

  procedure coverage_pause is
    l_return_code binary_integer;
  begin
    if not g_develop_mode then
      l_return_code := dbms_profiler.pause_profiler();
    end if;
  end;

  procedure coverage_resume is
    l_return_code binary_integer;
  begin
    l_return_code := dbms_profiler.resume_profiler();
  end;

  procedure coverage_stop is
    l_return_code binary_integer;
  begin
    if g_develop_mode then
      l_return_code := dbms_profiler.flush_data();
    else
      l_return_code := dbms_profiler.stop_profiler();
    end if;
  end;

  procedure coverage_stop_develop is
    l_return_code binary_integer;
  begin
    l_return_code := dbms_profiler.stop_profiler();
  end;

  function get_raw_coverage_data(a_object_owner varchar2, a_object_name varchar2) return unit_line_calls is
    type coverage_row is record (
      line  binary_integer,
      calls number(38,0)
    );
    type coverage_rows is table of coverage_row;
    l_tmp_data coverage_rows;
    l_results  unit_line_calls;
  begin
      select d.line#, d.total_occur
      bulk collect into l_tmp_data
        from plsql_profiler_units u
        join plsql_profiler_data d
          on u.runid = d.runid
         and u.unit_number = d.unit_number
       where u.runid = g_coverage_id
         and u.unit_owner = a_object_owner
         and u.unit_name = a_object_name
         --exclude specification
         and u.unit_type not in ('PACKAGE SPEC', 'TYPE SPEC', 'ANONYMOUS BLOCK');
    for i in 1 .. l_tmp_data.count loop
      l_results(l_tmp_data(i).line) := l_tmp_data(i).calls;
    end loop;
    return l_results;
  end;
end;
/
