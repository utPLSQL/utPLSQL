create or replace type body ut_output_table_buffer is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

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

  constructor function ut_output_table_buffer(self in out nocopy ut_output_table_buffer, a_output_id raw := null) return self as result is
  begin
    self.init(a_output_id, $$plsql_unit);
    return;
  end;

  overriding member procedure close(self in out nocopy ut_output_table_buffer) is
    pragma autonomous_transaction;
  begin
    self.last_message_id := self.last_message_id + 1;
    insert /*+ no_parallel */ into ut_output_buffer_tmp(output_id, message_id, is_finished)
    values (self.output_id, self.last_message_id, 1);
    commit;
    self.is_closed := 1;
  end;

  overriding member procedure send_line(self in out nocopy ut_output_table_buffer, a_text varchar2, a_item_type varchar2 := null) is
    pragma autonomous_transaction;
  begin
    if a_text is not null or a_item_type is not null then
      if length(a_text) > ut_utils.gc_max_storage_varchar2_len then
        self.send_lines(
          ut_utils.convert_collection(
            ut_utils.clob_to_table(a_text, ut_utils.gc_max_storage_varchar2_len)
            ),
          a_item_type
          );
      else
        self.last_message_id := self.last_message_id + 1;
        insert /*+ no_parallel */ into ut_output_buffer_tmp(output_id, message_id, text, item_type)
        values (self.output_id, self.last_message_id, a_text, a_item_type);
      end if;
      commit;
    end if;
  end;

  overriding member procedure send_lines(self in out nocopy ut_output_table_buffer, a_text_list ut_varchar2_rows, a_item_type varchar2 := null) is
    pragma autonomous_transaction;
  begin
    insert /*+ no_parallel */ into ut_output_buffer_tmp(output_id, message_id, text, item_type)
    select /*+ no_parallel */ self.output_id, self.last_message_id + rownum, t.column_value, a_item_type
      from table(a_text_list) t
     where t.column_value is not null or a_item_type is not null;
    self.last_message_id := self.last_message_id + SQL%rowcount;
    commit;
  end;

  overriding member procedure send_clob(self in out nocopy ut_output_table_buffer, a_text clob, a_item_type varchar2 := null) is
    pragma autonomous_transaction;
  begin
    if a_text is not null and a_text != empty_clob() or a_item_type is not null then
      if length(a_text) > ut_utils.gc_max_storage_varchar2_len then
        self.send_lines(
          ut_utils.convert_collection(
            ut_utils.clob_to_table(a_text, ut_utils.gc_max_storage_varchar2_len)
            ),
          a_item_type
          );
      else
        self.last_message_id := self.last_message_id + 1;
        insert /*+ no_parallel */ into ut_output_buffer_tmp(output_id, message_id, text, item_type)
        values (self.output_id, self.last_message_id, a_text, a_item_type);
      end if;
      commit;
    end if;
  end;

  overriding member function get_lines(a_initial_timeout natural := null, a_timeout_sec natural := null) return ut_output_data_rows pipelined is
    l_buffer_data        ut_varchar2_rows;
    l_item_types         ut_varchar2_rows;
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

    procedure get_data_from_buffer(
      a_max_message_id integer,
      a_buffer_data    out nocopy ut_varchar2_rows,
      a_item_types     out nocopy ut_varchar2_rows,
      a_finished_flags out nocopy ut_integer_list
    ) is
      pragma autonomous_transaction;
    begin
      delete /*+ no_parallel */ from (
                    select /*+ no_parallel */ *
                      from ut_output_buffer_tmp o
                     where o.output_id = self.output_id
                       and o.message_id <= a_max_message_id
                     order by o.message_id
                  ) d
      returning d.text, d.item_type, d.is_finished
      bulk collect into a_buffer_data, a_item_types, a_finished_flags;
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
      get_data_from_buffer( l_max_message_id, l_buffer_data, l_item_types, l_finished_flags);
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
          if l_buffer_data(i) is not null then
            pipe row(ut_output_data_row(l_buffer_data(i),l_item_types(i)));
          elsif l_finished_flags(i) = 1 then
            l_finished := true;
            exit;
          end if;
        end loop;
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

end;
/
