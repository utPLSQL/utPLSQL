create table ut_output_buffer_info_tmp$(
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
  /*
  * This table is not a global temporary table as it needs to allow cross-session data exchange
  * It is used however as a temporary table with multiple writers.
  * This is why it has very high initrans and has nologging
  */
  output_id      raw(32) not null,
  start_date     date not null,
  constraint ut_output_buffer_info_tmp_pk primary key(output_id)
) organization index nologging initrans 10
;

-- This is needed to be EBR ready as editioning view can only be created by edition enabled user
declare
  ex_nonedition_user exception;
  ex_view_doesnt_exist exception;
  pragma exception_init(ex_nonedition_user,-42314);
  pragma exception_init(ex_view_doesnt_exist,-942);
  v_view_source varchar2(32767);
begin
  begin
    execute immediate 'drop view ut_output_buffer_info_tmp';
  exception
    when ex_view_doesnt_exist then
      null;
  end;
  v_view_source := ' ut_output_buffer_info_tmp as
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
select output_id
      ,start_date
  from ut_output_buffer_info_tmp$';

  execute immediate 'create or replace editioning view '||v_view_source;
exception
  when ex_nonedition_user then
    execute immediate 'create or replace view '||v_view_source;
end;
/
