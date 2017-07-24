create or replace package ut_coverage_helper authid definer is
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

  --table of line calls indexed by line number
  --!!! this table is sparse!!!
  type unit_line_calls is table of number(38,0) index by binary_integer;

  function  is_develop_mode return boolean;

  procedure coverage_start(a_run_comment varchar2);

  /*
  * Start coverage in develop mode, where all internal calls to utPLSQL itself are also included
  */
  procedure coverage_start_develop;

  procedure coverage_stop;

  procedure coverage_stop_develop;

  procedure coverage_pause;

  procedure coverage_resume;

  function get_raw_coverage_data(a_object_owner varchar2, a_object_name varchar2) return unit_line_calls;
end;
/
