create or replace type body ut_output_table_buffer is
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

  constructor function ut_output_table_buffer(self in out nocopy ut_output_table_buffer) return self as result is
  begin
    init(sys_guid());
    cleanup_buffer();
    return;
  end;

  overriding member procedure init(self in out nocopy ut_output_table_buffer, a_output_id raw) is
    pragma autonomous_transaction;
  begin
    delete from ut_output_buffer_tmp where output_id = self.output_id;
    delete from ut_output_buffer_info_tmp where output_id = self.output_id;
    self.output_id := a_output_id;
    self.start_date := sysdate;
    insert into ut_output_buffer_info_tmp(output_id, start_date) values (self.output_id, self.start_date);
    commit;
  end;

  overriding member procedure send_line(self in ut_output_table_buffer, a_text varchar2) is
    l_text_list  ut_varchar2_rows;
    pragma autonomous_transaction;
  begin
    if a_text is not null then
      if length(a_text) > ut_utils.gc_max_storage_varchar2_len then
        l_text_list := ut_utils.convert_collection(ut_utils.clob_to_table(a_text, ut_utils.gc_max_storage_varchar2_len));
        insert
          into ut_output_buffer_tmp(output_id, message_id, text)
        select self.output_id, ut_message_id_seq.nextval, t.column_value
          from table(l_text_list) t;
      else
        insert into ut_output_buffer_tmp(output_id, message_id, text)
        values (self.output_id, ut_message_id_seq.nextval, a_text);
      end if;
      commit;
    end if;
  end;

  overriding member procedure close(self in ut_output_table_buffer) is
    pragma autonomous_transaction;
  begin
    insert into ut_output_buffer_tmp(output_id, message_id, is_finished)
    values (self.output_id, ut_message_id_seq.nextval, 1);
    commit;
  end;

  overriding member function get_lines(a_initial_timeout natural := null, a_timeout_sec natural := null) return ut_varchar2_rows pipelined is
    l_buffer_data        ut_varchar2_rows;
    l_already_waited_for number(10,2) := 0;
    l_finished           boolean := false;
    lc_init_wait_sec     constant naturaln := coalesce(a_initial_timeout, 60 * 1); -- 1 minute
    lc_max_wait_sec      constant naturaln := coalesce(a_timeout_sec, 60 * 60 * 4); -- 4 hours
    l_wait_for           integer := lc_init_wait_sec;
    lc_sleep_time        constant number(1,1) := 0.1; --sleep for 100 ms between checks
    function get_data_from_buffer return ut_varchar2_rows is
      l_results        ut_varchar2_rows;
      pragma autonomous_transaction;
    begin
      delete from (
        select *
          from ut_output_buffer_tmp where output_id = self.output_id order by message_id
        )
      returning text bulk collect into l_results;
      commit;
      return l_results;
    end;

  begin
    loop
      l_buffer_data := get_data_from_buffer();
      --nothing fetched from output, wait and try again
      if l_buffer_data.count = 0 then
        dbms_lock.sleep(lc_sleep_time);
        l_already_waited_for := l_already_waited_for + lc_sleep_time;
      else
        l_wait_for := lc_max_wait_sec;
        for i in 1 .. l_buffer_data.count loop
          if l_buffer_data(i) is not null then
            pipe row(l_buffer_data(i));
          else
            l_finished := true;
            exit;
          end if;
        end loop;
      end if;
      exit when l_already_waited_for >= l_wait_for or l_finished;
    end loop;
    return;
  end;

  overriding member function get_lines_cursor(a_initial_timeout natural := null, a_timeout_sec natural := null) return sys_refcursor is
    l_lines sys_refcursor;
  begin
    open l_lines for
      select column_value as text
        from table(self.get_lines(a_initial_timeout, a_timeout_sec));
    return l_lines;
  end;

  overriding member procedure lines_to_dbms_output(self in ut_output_table_buffer, a_initial_timeout natural := null, a_timeout_sec natural := null) is
    l_lines sys_refcursor;
    l_line varchar2(32767);
  begin
    l_lines := self.get_lines_cursor(a_initial_timeout, a_timeout_sec);
    loop
      fetch l_lines into l_line;
      exit when l_lines%notfound;
      dbms_output.put_line(l_line);
    end loop;
    close l_lines;
  end;

  member procedure cleanup_buffer(self in ut_output_table_buffer, a_retention_time_sec natural := null) is
    gc_buffer_retention_sec  constant naturaln := coalesce(a_retention_time_sec, 60 * 60 * 24); -- 24 hours
    l_retention_days         number := gc_buffer_retention_sec / (60 * 60 * 24);
    l_max_retention_date     date := sysdate - l_retention_days;
    pragma autonomous_transaction; -- the cleanup should initiate transaction
  begin
    delete from ut_output_buffer_tmp t
     where t.output_id
        in (select i.output_id from ut_output_buffer_info_tmp i where i.start_date <= l_max_retention_date);

    delete from ut_output_buffer_info_tmp i where i.start_date <= l_max_retention_date;
    commit;
  end;

end;
/
