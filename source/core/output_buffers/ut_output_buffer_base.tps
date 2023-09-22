create or replace type ut_output_buffer_base force authid definer as object(
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

  output_id                 raw(32),
  is_closed                 number(1,0),
  start_date                date,
  lock_handle               varchar2(30  byte),
  self_type                 varchar2(250 byte),
  member procedure init(self in out nocopy ut_output_buffer_base, a_output_id raw := null, a_self_type varchar2 := null),
  member procedure lock_buffer(a_timeout_sec number := null),
  member function timeout_producer_not_started( a_producer_started boolean, a_already_waited_sec number, a_init_wait_sec number ) return boolean,
  member function timeout_producer_not_finished(a_producer_finished boolean, a_already_waited_sec number, a_timeout_sec number) return boolean,
  member function get_lock_status return integer,
  member function get_lines_cursor(a_initial_timeout number := null, a_timeout_sec number := null) return sys_refcursor,
  member procedure lines_to_dbms_output(self in ut_output_buffer_base, a_initial_timeout number := null, a_timeout_sec number := null),
  member procedure cleanup_buffer(self in ut_output_buffer_base, a_retention_time_sec natural := null),
  member procedure remove_buffer_info(self in ut_output_buffer_base),
  member procedure close(self in out nocopy ut_output_buffer_base),
  not instantiable member procedure send_line(self in out nocopy ut_output_buffer_base, a_text varchar2, a_item_type varchar2 := null),
  not instantiable member procedure send_lines(self in out nocopy ut_output_buffer_base, a_text_list ut_varchar2_rows, a_item_type varchar2 := null),
  not instantiable member procedure send_clob(self in out nocopy ut_output_buffer_base, a_text clob, a_item_type varchar2 := null),
  not instantiable member function get_lines(a_initial_timeout number := null, a_timeout_sec number := null) return ut_output_data_rows pipelined
) not final not instantiable
/
