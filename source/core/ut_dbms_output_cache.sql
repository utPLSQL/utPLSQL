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
/*
* This table is not a global temporary table as it needs to allow cross-session data exchange
* It is used however as a temporary table with multiple writers.
* This is why it has very high initrans and has nologging
*/
declare
  l_tab_exist number;
begin
  select /*+ no_parallel */ count(*) into l_tab_exist from
  (select table_name from all_tables where table_name = 'UT_DBMS_OUTPUT_CACHE' and owner = sys_context('USERENV','CURRENT_SCHEMA')
   union all
   select synonym_name from all_synonyms where synonym_name = 'UT_DBMS_OUTPUT_CACHE' and owner = sys_context('USERENV','CURRENT_SCHEMA'));
  if l_tab_exist = 0 then
  
    execute immediate q'[create global temporary table ut_dbms_output_cache
                        (
                           seq_no         number(20,0) not null,
                           text           varchar2(4000),
                           constraint ut_dbms_output_cache_pk primary key(seq_no)
                        ) on commit preserve rows
                       ]';

  end if;
end;
/
