declare
  v_table_sql varchar2(32767);
  e_non_assm exception;
  pragma exception_init(e_non_assm, -43853);
begin
  v_table_sql := 'create table ut_output_clob_buffer_tmp(
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
  /*
  * This table is not a global temporary table as it needs to allow cross-session data exchange
  * It is used however as a temporary table with multiple writers.
  * This is why it has very high initrans and has nologging
  */
  output_id      raw(32) not null,
  message_id     number(38,0) not null,
  text           clob,
  item_type      varchar2(1000),
  is_finished    number(1,0) default 0 not null,
  constraint ut_output_clob_buffer_tmp_pk primary key(output_id, message_id),
  constraint ut_output_clob_buffer_tmp_ck check(
         is_finished = 0 and (text is not null or item_type is not null )
      or is_finished = 1 and text is null and item_type is null ),
  constraint ut_output_clob_buffer_tmp_fk foreign key (output_id) references ut_output_buffer_info_tmp(output_id) on delete cascade
) nologging initrans 100
';
  begin
    execute immediate
      v_table_sql || 'lob(text) store as securefile ut_output_text(retention none enable storage in row)';
  exception
    when e_non_assm then
      execute immediate
        v_table_sql || 'lob(text) store as basicfile ut_output_text(pctversion 0 enable storage in row)';

  end;
end;
/
