create or replace type body ut_output_clob_table_buffer is
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

  constructor function ut_output_clob_table_buffer(self in out nocopy ut_output_clob_table_buffer, a_output_id raw := null) return self as result is
  begin
    self.init(a_output_id, $$plsql_unit);
    return;
  end;

  overriding member procedure send_line(self in out nocopy ut_output_clob_table_buffer, a_text varchar2, a_item_type varchar2 := null) is
    pragma autonomous_transaction;
  begin
    if a_text is not null or a_item_type is not null then
      self.last_write_message_id := self.last_write_message_id + 1;
      insert /*+ no_parallel */ into ut_output_clob_buffer_tmp(output_id, message_id, text, item_type)
      values (self.output_id, self.last_write_message_id, a_text, a_item_type);
    end if;
    commit;
  end;

  overriding member procedure send_lines(self in out nocopy ut_output_clob_table_buffer, a_text_list ut_varchar2_rows, a_item_type varchar2 := null) is
    pragma autonomous_transaction;
  begin
    insert /*+ no_parallel */ into ut_output_clob_buffer_tmp(output_id, message_id, text, item_type)
    select /*+ no_parallel */ self.output_id, self.last_write_message_id + rownum, t.column_value, a_item_type
      from table(a_text_list) t
     where t.column_value is not null or a_item_type is not null;
    self.last_write_message_id := self.last_write_message_id + SQL%rowcount;
    commit;
  end;

  overriding member procedure send_clob(self in out nocopy ut_output_clob_table_buffer, a_text clob, a_item_type varchar2 := null) is
    pragma autonomous_transaction;
  begin
    if a_text is not null and a_text != empty_clob() or a_item_type is not null then
      self.last_write_message_id := self.last_write_message_id + 1;
      insert /*+ no_parallel */ into ut_output_clob_buffer_tmp(output_id, message_id, text, item_type)
      values (self.output_id, self.last_write_message_id, a_text, a_item_type);
    end if;
    commit;
  end;

  overriding member procedure get_data_from_buffer_table(
      self in ut_output_clob_table_buffer,
      a_last_read_message_id in out nocopy integer,
      a_buffer_data    out nocopy ut_output_data_rows,
      a_buffer_rowids  out nocopy ut_varchar2_rows,
      a_finished_flags out nocopy ut_integer_list
    ) is
    lc_bulk_limit           constant integer     := 5000;
  begin
    a_last_read_message_id := coalesce(a_last_read_message_id, 0);
    with ordered_buffer as (
      select  /*+ no_parallel index(a) */ ut_output_data_row(a.text, a.item_type), rowidtochar(a.rowid), is_finished
        from ut_output_clob_buffer_tmp a
       where a.output_id = self.output_id
         and a.message_id <= a_last_read_message_id + lc_bulk_limit
       order by a.message_id
    )
    select /*+ no_parallel */ b.*
      bulk collect into a_buffer_data, a_buffer_rowids, a_finished_flags
      from ordered_buffer b;
    a_last_read_message_id := a_last_read_message_id + a_finished_flags.count;
  end;

  overriding member procedure remove_read_data(self in ut_output_clob_table_buffer, a_buffer_rowids ut_varchar2_rows) is
      pragma autonomous_transaction;
  begin
    forall i in 1 .. a_buffer_rowids.count
      delete from ut_output_clob_buffer_tmp a
       where rowid = chartorowid(a_buffer_rowids(i));
    commit;
  end;

end;
/
