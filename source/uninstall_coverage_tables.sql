/*
  utPLSQL - Version 3
  Copyright 2016 - 2026 utPLSQL Project

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

set echo off
set feedback off
begin
  for to_be_dopped in (
  select table_name
  from all_tables
  where table_name in (
    'PLSQL_PROFILER_RUNS','PLSQL_PROFILER_UNITS','PLSQL_PROFILER_DATA',
    'DBMSPCC_BLOCKS','DBMSPCC_RUNS','DBMSPCC_UNITS'
  )
        and owner = sys_context( 'USERENV', 'CURRENT_SCHEMA' )
  )
  loop
    execute immediate 'drop table '||to_be_dopped.table_name||' cascade constraints purge';
    dbms_output.put_line('Table '||to_be_dopped.table_name||' dropped');
  end loop;
end;
/

declare
  l_seq_exist number;
begin
  select count(*) into l_seq_exist
  from all_sequences
  where sequence_name = 'PLSQL_PROFILER_RUNNUMBER'
        and sequence_owner = sys_context('USERENV','CURRENT_SCHEMA');
  if l_seq_exist = 1 then
    execute immediate 'drop sequence plsql_profiler_runnumber';
    dbms_output.put_line('Sequence PLSQL_PROFILER_RUNNUMBER dropped');
  end if;
end;
/

