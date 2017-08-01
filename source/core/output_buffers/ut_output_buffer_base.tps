create or replace type ut_output_buffer_base authid definer as object(
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

  output_id                 raw(32),
  member procedure init(self in out nocopy ut_output_buffer_base, a_output_id raw),
  not instantiable member procedure send_line(self in ut_output_buffer_base, a_text varchar2),
  not instantiable member procedure close(self in ut_output_buffer_base),
  not instantiable member function get_lines(a_initial_timeout natural := null, a_timeout_sec natural := null) return ut_varchar2_rows pipelined,
  not instantiable member function get_lines_cursor(a_initial_timeout natural := null, a_timeout_sec natural := null) return sys_refcursor,
  not instantiable member procedure lines_to_dbms_output(self in ut_output_buffer_base, a_initial_timeout natural := null, a_timeout_sec natural := null)
) not final not instantiable
/
