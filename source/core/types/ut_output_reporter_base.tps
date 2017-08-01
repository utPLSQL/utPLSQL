create or replace type ut_output_reporter_base under ut_reporter_base(
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
  output_buffer ut_output_buffer_base,
  member procedure init(self in out nocopy ut_output_reporter_base, a_self_type varchar2, a_output_buffer ut_output_buffer_base := null),
  overriding member procedure set_reporter_id(self in out nocopy ut_output_reporter_base, a_reporter_id raw),
  member procedure print_text(self in out nocopy ut_output_reporter_base, a_text varchar2),

  member procedure print_clob(self in out nocopy ut_output_reporter_base, a_clob clob),

  final member function get_lines(a_initial_timeout natural := null, a_timeout_sec natural := null) return ut_varchar2_rows pipelined,
  final member function get_lines_cursor(a_initial_timeout natural := null, a_timeout_sec natural := null) return sys_refcursor,
  final member procedure lines_to_dbms_output(self in ut_output_reporter_base, a_initial_timeout natural := null, a_timeout_sec natural := null),
  overriding final member procedure finalize(self in out nocopy ut_output_reporter_base)
)
not final not instantiable
/
