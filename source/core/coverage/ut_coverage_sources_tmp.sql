create global temporary table ut_coverage_sources_tmp$(
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
  full_name varchar2(4000),
  owner varchar2(250),
  name  varchar2(250),
  line  number(38,0),
  to_be_skipped varchar2(1),
  text varchar2(4000),
  constraint ut_coverage_sources_tmp_pk primary key (owner,name,line)
) on commit preserve rows;

create unique index ut_coverage_sources_tmp_uk on ut_coverage_sources_tmp$ (owner,name,to_be_skipped, line);

declare
  ex_nonedition_user exception;
  ex_view_doesnt_exist exception;
  pragma exception_init(ex_nonedition_user,-42314);
  pragma exception_init(ex_view_doesnt_exist,-942);
  v_view_source varchar2(32767);
begin
  begin
    execute immediate 'drop view ut_coverage_sources_tmp';
  exception
    when ex_view_doesnt_exist then
      null;
  end;
  v_view_source := ' ut_coverage_sources_tmp as
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
select full_name
      ,owner
      ,name
      ,line
      ,to_be_skipped
      ,text
  from ut_coverage_sources_tmp$';

  execute immediate 'create or replace editioning view '||v_view_source;
exception
  when ex_nonedition_user then
    execute immediate 'create or replace view '||v_view_source;
end;
/
