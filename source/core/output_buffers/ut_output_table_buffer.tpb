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
      if length(a_text) > ut_utils.gc_max_storage_varchar2_len then
        self.send_lines(
          ut_utils.convert_collection(
            ut_utils.clob_to_table(a_text, ut_utils.gc_max_storage_varchar2_len)
            ),
          a_item_type
          );
      else
        self.last_write_message_id := self.last_write_message_id + 1;
        insert /*+ no_parallel */ into ut_output_buffer_tmp(output_id, message_id, text, item_type)
        values (self.output_id, self.last_write_message_id, a_text, a_item_type);
      end if;
      commit;
    end if;
  end;

  overriding member procedure send_lines(self in out nocopy ut_output_table_buffer, a_text_list ut_varchar2_rows, a_item_type varchar2 := null) is
    pragma autonomous_transaction;
  begin
    insert /*+ no_parallel */ into ut_output_buffer_tmp(output_id, message_id, text, item_type)
    select /*+ no_parallel */ self.output_id, self.last_write_message_id + rownum, t.column_value, a_item_type
      from table(a_text_list) t
     where t.column_value is not null or a_item_type is not null;
    self.last_write_message_id := self.last_write_message_id + SQL%rowcount;
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
        self.last_write_message_id := self.last_write_message_id + 1;
        insert /*+ no_parallel */ into ut_output_buffer_tmp(output_id, message_id, text, item_type)
        values (self.output_id, self.last_write_message_id, a_text, a_item_type);
      end if;
      commit;
    end if;
  end;

  overriding member procedure lines_to_dbms_output(self in ut_output_table_buffer, a_initial_timeout number := null, a_timeout_sec number := null) is
    l_data      sys_refcursor;
    l_text      varchar2(32767);
    l_item_type varchar2(32767);
  begin
    l_data := self.get_lines_cursor(a_initial_timeout, a_timeout_sec);
    loop
      fetch l_data into l_text, l_item_type;
      exit when l_data%notfound;
      dbms_output.put_line(l_text);
    end loop;
    close l_data;
  end;

  overriding member procedure get_data_from_buffer_table(
    self in ut_output_table_buffer,
    a_last_read_message_id in out nocopy integer,
    a_buffer_data    out nocopy ut_output_data_rows,
    a_buffer_rowids  out nocopy ut_varchar2_rows,
    a_finished_flags out nocopy ut_integer_list
  ) is
    lc_bulk_limit           constant integer     := 20000;
    pragma autonomous_transaction;
  begin
    a_last_read_message_id := coalesce(a_last_read_message_id,0);
    delete /*+ no_parallel */ from (
                  select /*+ no_parallel */ *
                    from ut_output_buffer_tmp o
                   where o.output_id = self.output_id
                     and o.message_id <= a_last_read_message_id + lc_bulk_limit
                   order by o.message_id
                ) d
    returning ut_output_data_row(d.text, d.item_type), d.is_finished
    bulk collect into a_buffer_data, a_finished_flags;
    a_last_read_message_id := a_last_read_message_id + a_finished_flags.count;
    commit;
  end;

  overriding member procedure remove_read_data(self in ut_output_table_buffer, a_buffer_rowids ut_varchar2_rows) is
  begin
    null;
  end;

end;
/
