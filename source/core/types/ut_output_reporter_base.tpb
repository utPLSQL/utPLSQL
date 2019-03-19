create or replace type body ut_output_reporter_base is
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

  constructor function ut_output_reporter_base(self in out nocopy ut_output_reporter_base) return self as result is
  begin
    return;
  end;

  member procedure init(self in out nocopy ut_output_reporter_base, a_self_type varchar2, a_output_buffer ut_output_buffer_base := null) is
  begin
    (self as ut_reporter_base).init(a_self_type);
    self.output_buffer := coalesce(a_output_buffer, ut_output_table_buffer());
    self.set_reporter_id(self.output_buffer.output_id);
  end;

  overriding member procedure set_reporter_id(self in out nocopy ut_output_reporter_base, a_reporter_id raw) is
  begin
    self.id := a_reporter_id;
    self.output_buffer.output_id := a_reporter_id;
  end;

  overriding member procedure before_calling_run(self in out nocopy ut_output_reporter_base, a_run in ut_run) is
    l_output_table_buffer ut_output_table_buffer;
  begin
    (self as ut_reporter_base).before_calling_run(a_run);
    l_output_table_buffer := treat(self.output_buffer as ut_output_table_buffer);
  end;

  member procedure print_text(self in out nocopy ut_output_reporter_base, a_text varchar2, a_item_type varchar2 := null) is
  begin
    self.output_buffer.send_line(a_text, a_item_type);
  end;

  member procedure print_text_lines(self in out nocopy ut_output_reporter_base, a_text_lines ut_varchar2_rows, a_item_type varchar2 := null) is
  begin
    self.output_buffer.send_lines(a_text_lines, a_item_type);
  end;

  member procedure print_clob(self in out nocopy ut_output_reporter_base, a_clob clob, a_item_type varchar2 := null) is
  begin
    self.output_buffer.send_clob( a_clob, a_item_type );
  end;

  final member function get_lines(a_initial_timeout natural := null, a_timeout_sec natural) return ut_output_data_rows pipelined is
  begin
    for i in (select value(x) val from table(self.output_buffer.get_lines(a_initial_timeout, a_timeout_sec)) x ) loop
      pipe row (i.val);
    end loop;
  end;

  final member function get_lines_cursor(a_initial_timeout natural := null, a_timeout_sec natural) return sys_refcursor is
  begin
    return self.output_buffer.get_lines_cursor(a_initial_timeout, a_timeout_sec);
  end;

  final member procedure lines_to_dbms_output(self in ut_output_reporter_base, a_initial_timeout natural := null, a_timeout_sec natural) is
  begin
    self.output_buffer.lines_to_dbms_output(a_initial_timeout, a_timeout_sec);
  end;

  overriding final member procedure on_finalize(self in out nocopy ut_output_reporter_base, a_run in ut_run) is
  begin
    self.output_buffer.close();
  end;

  overriding member procedure on_initialize(self in out nocopy ut_output_reporter_base, a_run in ut_run) is
  begin
    self.output_buffer.send_line(null, 'initialize');
  end;

end;
/
