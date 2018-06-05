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
    execute immediate 'drop table '||to_be_dopped.table_name||' cascade constraints';
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

