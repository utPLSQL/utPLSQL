create or replace type ut_output_reporter_base under ut_reporter_base(
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project

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
  constructor function ut_output_reporter_base(self in out nocopy ut_output_reporter_base) return self as result,
  member procedure init(self in out nocopy ut_output_reporter_base, a_self_type varchar2, a_output_buffer ut_output_buffer_base := null),
  overriding member procedure set_reporter_id(self in out nocopy ut_output_reporter_base, a_reporter_id raw),
  member function  set_reporter_id(self in ut_output_reporter_base, a_reporter_id raw) return ut_output_reporter_base,
  overriding member procedure before_calling_run(self in out nocopy ut_output_reporter_base, a_run in ut_run),
  
  member procedure print_text(self in out nocopy ut_output_reporter_base, a_text varchar2, a_item_type varchar2 := null),
  member procedure print_text_lines(self in out nocopy ut_output_reporter_base, a_text_lines ut_varchar2_rows, a_item_type varchar2 := null),
  member procedure print_clob(self in out nocopy ut_output_reporter_base, a_clob clob, a_item_type varchar2 := null),

  final member function get_lines(a_initial_timeout natural := null, a_timeout_sec natural := null) return ut_output_data_rows pipelined,
  final member function get_lines_cursor(a_initial_timeout natural := null, a_timeout_sec natural := null) return sys_refcursor,
  final member procedure lines_to_dbms_output(self in ut_output_reporter_base, a_initial_timeout natural := null, a_timeout_sec natural := null),
  overriding final member procedure on_finalize(self in out nocopy ut_output_reporter_base, a_run in ut_run),
  overriding member procedure on_initialize(self in out nocopy ut_output_reporter_base, a_run in ut_run)
)
not final not instantiable
/
