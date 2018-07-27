create or replace package ut_coverage_helper_profiler authid definer is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2018 utPLSQL Project

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

  procedure coverage_start(a_run_comment in varchar2,a_coverage_id out integer);

  procedure coverage_stop;

  procedure coverage_pause;

  procedure coverage_resume;

  function get_raw_coverage_data(a_object_owner varchar2, a_object_name varchar2, a_coverage_id integer) return ut_coverage_helper.t_unit_line_calls;

end;
/
