create or replace package ut_block_coverage_helper authid definer is
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

  procedure coverage_start(a_run_comment in varchar2,a_coverage_id out integer);

  procedure coverage_stop;

  function get_raw_coverage_data_block(a_object_owner varchar2, a_object_name varchar2) return ut_coverage_helper.t_unit_line_calls;

end;
/
