create or replace type body ut_output_table_buffer is
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

  constructor function ut_output_table_buffer(self in out nocopy ut_output_table_buffer, a_output_id raw := null) return self as result is
  begin
    self.init(a_output_id, $$plsql_unit);
    return;
  end;

  overriding member procedure send_line(self in out nocopy ut_output_table_buffer, a_text varchar2, a_item_type varchar2 := null) is
    pragma autonomous_transaction;
  begin
    if a_text is not null or a_item_type is not null then
      if lengthb(a_text) > ut_utils.gc_max_storage_varchar2_len then
        self.send_lines(
          ut_utils.convert_collection(
            ut_utils.clob_to_table(a_text, ut_utils.gc_max_storage_varchar2_len)
            ),
          a_item_type
          );
      else
        insert /*+ no_parallel */ into ut_output_buffer_tmp(output_id, message_id, text, item_type)
        values (self.output_id, ut_output_buffer_tmp_seq.nextval, a_text, a_item_type);
      end if;
      commit;
    end if;
  end;

  overriding member procedure send_lines(self in out nocopy ut_output_table_buffer, a_text_list ut_varchar2_rows, a_item_type varchar2 := null) is
    pragma autonomous_transaction;
  begin
    insert /*+ no_parallel */ into ut_output_buffer_tmp(output_id, message_id, text, item_type)
    select /*+ no_parallel */ self.output_id, ut_output_buffer_tmp_seq.nextval, t.column_value, a_item_type
      from table(a_text_list) t
     where t.column_value is not null or a_item_type is not null;
    commit;
  end;

  overriding member procedure send_clob(self in out nocopy ut_output_table_buffer, a_text clob, a_item_type varchar2 := null) is
    pragma autonomous_transaction;
  begin
    if a_text is not null and a_text != empty_clob() or a_item_type is not null then
      if ut_utils.lengthb_clob(a_text) > ut_utils.gc_max_storage_varchar2_len then
        self.send_lines(
          ut_utils.convert_collection(
            ut_utils.clob_to_table(a_text, ut_utils.gc_max_storage_varchar2_len)
            ),
          a_item_type
          );
      else
        insert /*+ no_parallel */ into ut_output_buffer_tmp(output_id, message_id, text, item_type)
        values (self.output_id, ut_output_buffer_tmp_seq.nextval, a_text, a_item_type);
      end if;
      commit;
    end if;
  end;

  overriding member procedure lines_to_dbms_output(self in ut_output_table_buffer, a_initial_timeout number := null, a_timeout_sec number := null) is
    l_data      sys_refcursor;
    l_text      ut_varchar2_rows;
    l_item_type ut_varchar2_rows;
  begin
    l_data := self.get_lines_cursor(a_initial_timeout, a_timeout_sec);
    loop
      fetch l_data bulk collect into l_text, l_item_type limit 10000;
      for idx in 1 .. l_text.count loop
        dbms_output.put_line(l_text(idx));
      end loop;
      exit when l_data%notfound;
    end loop;
    close l_data;
  end;

  /* Important note.
     This function code is almost duplicated between two types for performance reasons.
     The pipe row clause is much faster on VARCHAR2 then it is on clob.
     That is the key reason for two implementations.
  */
  overriding member function get_lines(a_initial_timeout number := null, a_timeout_sec number := null) return ut_output_data_rows pipelined is
    lc_init_wait_sec        constant number := coalesce(a_initial_timeout, 10 );
    l_buffer_texts          ut_varchar2_rows;
    l_buffer_item_types     ut_varchar2_rows;
    l_finished_flags        ut_integer_list;
    l_already_waited_sec    number(10,2) := 0;
    l_finished              boolean := false;
    l_sleep_time            number(2,1);
    l_lock_status           integer;
    l_producer_started      boolean := false;
    l_producer_finished     boolean := false;

  procedure get_data_from_buffer_table(
    a_buffer_texts         out nocopy ut_varchar2_rows,
    a_buffer_item_types    out nocopy ut_varchar2_rows,
    a_finished_flags       out nocopy ut_integer_list
  ) is
    lc_bulk_limit           constant integer     := 20000;
    pragma autonomous_transaction;
  begin
    delete /*+ no_parallel */ from (
                  select /*+ no_parallel */ *
                    from ut_output_buffer_tmp a
                   where a.output_id = self.output_id
                     and a.message_id <= (select min(message_id) from ut_output_buffer_tmp o where o.output_id = self.output_id) + lc_bulk_limit
                   order by a.message_id
                ) d
    returning d.text, d.item_type, d.is_finished
    bulk collect into a_buffer_texts, a_buffer_item_types, a_finished_flags;
    commit;
  end;
  begin
    while not l_finished loop

      l_sleep_time := case when l_already_waited_sec >= 1 then 0.5 else 0.1 end;
      l_lock_status := self.get_lock_status();
      get_data_from_buffer_table( l_buffer_texts, l_buffer_item_types, l_finished_flags );

      if l_buffer_texts.count > 0 then
        l_already_waited_sec := 0;
        for i in 1 .. l_buffer_texts.count loop
          if l_buffer_texts(i) is not null then
            pipe row( ut_output_data_row(l_buffer_texts(i), l_buffer_item_types(i)) );
          elsif l_finished_flags(i) = 1 then
            l_finished := true;
            exit;
          end if;
        end loop;
      else
        --nothing fetched from output, wait.
        dbms_lock.sleep(l_sleep_time);
        l_already_waited_sec := l_already_waited_sec + l_sleep_time;
      end if;

      l_producer_started := (l_lock_status <> 0 or l_buffer_texts.count > 0) or l_producer_started;
      l_producer_finished := (l_producer_started and l_lock_status = 0 and l_buffer_texts.count = 0) or l_producer_finished;

      l_finished :=
        self.timeout_producer_not_finished(l_producer_finished, l_already_waited_sec, a_timeout_sec)
        or self.timeout_producer_not_started(l_producer_started, l_already_waited_sec, lc_init_wait_sec)
        or l_producer_finished
        or l_finished;

    end loop;

    self.remove_buffer_info();
    return;
  end;

end;
/
