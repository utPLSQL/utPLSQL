create or replace type body ut_output_clob_table_buffer is
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

  constructor function ut_output_clob_table_buffer(self in out nocopy ut_output_clob_table_buffer, a_output_id raw := null) return self as result is
  begin
    self.output_id := coalesce(a_output_id, sys_guid());
    self.start_date := sysdate;
    self.last_message_id := 0;
    self.init();
    self.cleanup_buffer();
    return;
  end;

  overriding member procedure init(self in out nocopy ut_output_clob_table_buffer) is
    pragma autonomous_transaction;
    l_exists int;
  begin
    select count(*) into l_exists from ut_output_buffer_info_tmp where output_id = self.output_id;
    if ( l_exists > 0 ) then
      update ut_output_buffer_info_tmp set start_date = self.start_date where output_id = self.output_id;
    else
      insert into ut_output_buffer_info_tmp(output_id, start_date) values (self.output_id, self.start_date);
    end if;
    commit;
  end;

  overriding member procedure close(self in out nocopy ut_output_clob_table_buffer) is
    pragma autonomous_transaction;
  begin
    self.last_message_id := self.last_message_id + 1;
    insert into ut_output_clob_buffer_tmp(output_id, message_id, is_finished)
    values (self.output_id, self.last_message_id, 1);
    commit;
  end;

  overriding member procedure send_line(self in out nocopy ut_output_clob_table_buffer, a_text varchar2, a_item_type varchar2 := null) is
    pragma autonomous_transaction;
  begin
    if a_text is not null or a_item_type is not null then
      self.last_message_id := self.last_message_id + 1;
      insert into ut_output_clob_buffer_tmp(output_id, message_id, text, item_type)
      values (self.output_id, self.last_message_id, a_text, a_item_type);
    end if;
    commit;
  end;

  overriding member procedure send_lines(self in out nocopy ut_output_clob_table_buffer, a_text_list ut_varchar2_rows, a_item_type varchar2 := null) is
    pragma autonomous_transaction;
  begin
    insert into ut_output_clob_buffer_tmp(output_id, message_id, text, item_type)
    select self.output_id, self.last_message_id + rownum, t.column_value, a_item_type
      from table(a_text_list) t
     where t.column_value is not null or a_item_type is not null;
    self.last_message_id := self.last_message_id + a_text_list.count;
    commit;
  end;

  overriding member procedure send_clob(self in out nocopy ut_output_clob_table_buffer, a_text clob, a_item_type varchar2 := null) is
    pragma autonomous_transaction;
  begin
    if a_text is not null and a_text != empty_clob() or a_item_type is not null then
      self.last_message_id := self.last_message_id + 1;
      insert into ut_output_clob_buffer_tmp(output_id, message_id, text, item_type)
      values (self.output_id, self.last_message_id, a_text, a_item_type);
    end if;
    commit;
  end;

  overriding member function get_lines(a_initial_timeout natural := null, a_timeout_sec natural := null) return ut_output_data_rows pipelined is
    type t_rowid_tab     is table of urowid;
    l_message_rowids     t_rowid_tab;
    l_buffer_data        ut_output_data_rows;
    l_finished_flags     ut_integer_list;
    l_already_waited_for number(10,2) := 0;
    l_finished           boolean := false;
    lc_init_wait_sec     constant naturaln := coalesce(a_initial_timeout, 60 ); -- 1 minute
    lc_max_wait_sec      constant naturaln := coalesce(a_timeout_sec, 60 * 60 * 4); -- 4 hours
    l_wait_for           integer := lc_init_wait_sec;
    lc_short_sleep_time  constant number(1,1) := 0.1; --sleep for 100 ms between checks
    lc_long_sleep_time   constant number(1) := 1;     --sleep for 1 s when waiting long
    lc_long_wait_time    constant number(1) := 1;     --waiting more than 1 sec
    l_sleep_time         number(2,1) := lc_short_sleep_time;
    lc_bulk_limit        constant integer := 5000;
    l_max_message_id     integer := lc_bulk_limit;

    procedure remove_read_data(a_message_rowids t_rowid_tab) is
      pragma autonomous_transaction;
    begin
      forall i in 1 .. a_message_rowids.count
        delete from ut_output_clob_buffer_tmp a
         where rowid = a_message_rowids(i);
      commit;
    end;

    procedure remove_buffer_info is
      pragma autonomous_transaction;
    begin
      delete from ut_output_buffer_info_tmp a
       where a.output_id = self.output_id;
      commit;
    end;

    begin
    while not l_finished loop
      with ordered_buffer as (
        select /*+ index(a) */ a.rowid, ut_output_data_row(a.text, a.item_type), is_finished
          from ut_output_clob_buffer_tmp a
         where a.output_id = self.output_id
           and a.message_id <= l_max_message_id
         order by a.message_id
      )
      select b.*
        bulk collect into l_message_rowids, l_buffer_data, l_finished_flags
        from ordered_buffer b;

      --nothing fetched from output, wait and try again
      if l_buffer_data.count = 0 then
        $if dbms_db_version.version >= 18 $then
          dbms_session.sleep(l_sleep_time);
        $else
          dbms_lock.sleep(l_sleep_time);
        $end
        l_already_waited_for := l_already_waited_for + l_sleep_time;
        if l_already_waited_for > lc_long_wait_time then
          l_sleep_time := lc_long_sleep_time;
        end if;
      else
        --reset wait time
        -- we wait lc_max_wait_sec for new message
        l_wait_for := lc_max_wait_sec;
        l_already_waited_for := 0;
        l_sleep_time := lc_short_sleep_time;
        for i in 1 .. l_buffer_data.count loop
          if l_buffer_data(i).text is not null then
            pipe row(l_buffer_data(i));
          elsif l_finished_flags(i) = 1 then
            l_finished := true;
            exit;
          end if;
        end loop;
        remove_read_data(l_message_rowids);
        l_max_message_id := l_max_message_id + lc_bulk_limit;
      end if;
      if l_finished or l_already_waited_for >= l_wait_for then
        remove_buffer_info();
        if l_already_waited_for > 0 and l_already_waited_for >= l_wait_for then
          raise_application_error(
            ut_utils.gc_out_buffer_timeout,
            'Timeout occurred while waiting for output data. Waited for: '||l_already_waited_for||' seconds.'
          );
        end if;
      end if;
    end loop;
    return;
  end;

  overriding member function get_lines_cursor(a_initial_timeout natural := null, a_timeout_sec natural := null) return sys_refcursor is
    l_lines sys_refcursor;
  begin
    open l_lines for
      select text, item_type
        from table(self.get_lines(a_initial_timeout, a_timeout_sec));
    return l_lines;
  end;

  overriding member procedure lines_to_dbms_output(self in ut_output_clob_table_buffer, a_initial_timeout natural := null, a_timeout_sec natural := null) is
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

  member procedure cleanup_buffer(self in ut_output_clob_table_buffer, a_retention_time_sec natural := null) is
    gc_buffer_retention_sec  constant naturaln := coalesce(a_retention_time_sec, 60 * 60 * 24); -- 24 hours
    l_retention_days         number := gc_buffer_retention_sec / (60 * 60 * 24);
    l_max_retention_date     date := sysdate - l_retention_days;
    pragma autonomous_transaction;
  begin
    delete from ut_output_clob_buffer_tmp t
     where t.output_id
        in (select i.output_id from ut_output_buffer_info_tmp i where i.start_date <= l_max_retention_date);

    delete from ut_output_buffer_info_tmp i where i.start_date <= l_max_retention_date;
    commit;
  end;

end;
/
