create or replace type ut_output_table_buffer under ut_output_buffer_base (
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

  constructor function ut_output_table_buffer(self in out nocopy ut_output_table_buffer, a_output_id raw := null) return self as result,
  overriding member procedure send_line(self in out nocopy ut_output_table_buffer, a_text varchar2, a_item_type varchar2 := null),
  overriding member procedure send_lines(self in out nocopy ut_output_table_buffer, a_text_list ut_varchar2_rows, a_item_type varchar2 := null),
  overriding member procedure send_clob(self in out nocopy ut_output_table_buffer, a_text clob, a_item_type varchar2 := null),
  overriding member procedure get_data_from_buffer_table(
      self in ut_output_table_buffer,
      a_last_read_message_id in out nocopy integer,
      a_buffer_data    out nocopy ut_output_data_rows,
      a_buffer_rowids  out nocopy ut_varchar2_rows,
      a_finished_flags out nocopy ut_integer_list
    ),
  overriding member procedure remove_read_data(self in ut_output_table_buffer, a_buffer_rowids ut_varchar2_rows)
) not final
/
