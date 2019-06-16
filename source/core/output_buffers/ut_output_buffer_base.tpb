create or replace type body ut_output_buffer_base is
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

  member procedure init(self in out nocopy ut_output_buffer_base, a_output_id raw := null, a_self_type varchar2 := null) is
    pragma autonomous_transaction;
    l_exists int;
  begin
    cleanup_buffer();
    self.self_type := coalesce(a_self_type,self.self_type);
    self.output_id := coalesce(a_output_id, self.output_id, sys_guid());
    self.start_date := coalesce(self.start_date, sysdate);
    self.last_message_id := 0;
    select count(*) into l_exists from ut_output_buffer_info_tmp where output_id = self.output_id;
    if ( l_exists > 0 ) then
      update ut_output_buffer_info_tmp set start_date = self.start_date where output_id = self.output_id;
    else
      insert into ut_output_buffer_info_tmp(output_id, start_date) values (self.output_id, self.start_date);
    end if;
    commit;
    self.is_closed := 0;
  end;

  member function get_lines_cursor(a_initial_timeout natural := null, a_timeout_sec natural := null) return sys_refcursor is
    l_lines sys_refcursor;
  begin
    open l_lines for
      select text, item_type
        from table(self.get_lines(a_initial_timeout, a_timeout_sec));
    return l_lines;
  end;

    member procedure lines_to_dbms_output(self in ut_output_buffer_base, a_initial_timeout natural := null, a_timeout_sec natural := null) is
    l_data      sys_refcursor;
    l_clob      clob;
    l_item_type varchar2(32767);
    l_lines     ut_varchar2_list;
  begin
    l_data := self.get_lines_cursor(a_initial_timeout, a_timeout_sec);
    loop
      fetch l_data into l_clob, l_item_type;
      exit when l_data%notfound;
      l_lines := ut_utils.clob_to_table(l_clob);
      for i in 1 .. l_lines.count loop
        dbms_output.put_line(l_lines(i));
      end loop;
    end loop;
    close l_data;
  end;

  member procedure cleanup_buffer(self in ut_output_buffer_base, a_retention_time_sec natural := null) is
    gc_buffer_retention_sec  constant naturaln := coalesce(a_retention_time_sec, 60 * 60 * 24); -- 24 hours
    l_retention_days         number := gc_buffer_retention_sec / (60 * 60 * 24);
    l_max_retention_date     date := sysdate - l_retention_days;
    pragma autonomous_transaction;
  begin
    delete from ut_output_buffer_info_tmp i where i.start_date <= l_max_retention_date;
    commit;
  end;

end;
/