create or replace type body ut_output_reporter_base is
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

  member procedure print_text(self in out nocopy ut_output_reporter_base, a_text varchar2) is
  begin
    ut_output_buffer.send_line(self,a_text);
  end;

  final member function get_lines return ut_varchar2_rows pipelined is
  begin
    for i in (select column_value from table(ut_output_buffer.get_lines(self.reporter_id))) loop
      pipe row (i.column_value);
    end loop;
  end;

  final member function get_lines_cursor return sys_refcursor is
  begin
    return ut_output_buffer.get_lines_cursor(self.reporter_id);
  end;

  final member procedure lines_to_dbms_output(self in ut_output_reporter_base) is
  begin
    ut_output_buffer.lines_to_dbms_output(self.reporter_id);
  end;

  final member function get_lines(a_timeout_sec naturaln) return ut_varchar2_rows pipelined is
  begin
    for i in (select column_value from table(ut_output_buffer.get_lines(self.reporter_id, a_timeout_sec))) loop
      pipe row (i.column_value);
    end loop;
  end;

  final member function get_lines_cursor(a_timeout_sec naturaln) return sys_refcursor is
  begin
    return ut_output_buffer.get_lines_cursor(self.reporter_id, a_timeout_sec);
  end;

  final member procedure lines_to_dbms_output(self in ut_output_reporter_base, a_timeout_sec naturaln) is
  begin
    ut_output_buffer.lines_to_dbms_output(self.reporter_id, a_timeout_sec);
  end;

  member procedure print_clob(self in out nocopy ut_output_reporter_base, a_clob clob) is
    l_lines ut_varchar2_list;
  begin
    if a_clob is not null and dbms_lob.getlength(a_clob) > 0 then
      l_lines := ut_utils.clob_to_table(a_clob);
      for i in 1 .. l_lines.count loop
        self.print_text(l_lines(i));
      end loop;
    end if;
  end;

  overriding final member procedure finalize(self in out nocopy ut_output_reporter_base) is
  begin
    ut_output_buffer.close(self);
    ut_output_buffer.cleanup_buffer();
  end;

end;
/
