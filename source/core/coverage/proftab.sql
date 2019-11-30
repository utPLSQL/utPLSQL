declare
  l_tab_exist number;
begin
  select count(*) into l_tab_exist from 
  (select table_name from all_tables where table_name = 'PLSQL_PROFILER_RUNS' and owner = sys_context('USERENV','CURRENT_SCHEMA')
   union all
   select synonym_name from all_synonyms where synonym_name = 'PLSQL_PROFILER_RUNS' and owner = sys_context('USERENV','CURRENT_SCHEMA'));
  if l_tab_exist = 0 then
    execute immediate q'[create table plsql_profiler_runs
(
  runid           number primary key,  -- unique run identifier,
                                       -- from plsql_profiler_runnumber
  related_run     number,              -- runid of related run (for client/
                                       --     server correlation)
  run_owner       varchar2(128),        -- user who started run
  run_date        date,                -- start time of run
  run_comment     varchar2(2047),      -- user provided comment for this run
  run_total_time  number,              -- elapsed time for this run
  run_system_info varchar2(2047),      -- currently unused
  run_comment1    varchar2(2047),      -- additional comment
  spare1          varchar2(256)        -- unused
)]';
    execute immediate q'[comment on table plsql_profiler_runs is
        'Run-specific information for the PL/SQL profiler']';
    dbms_output.put_line('PLSQL_PROFILER_RUNS table created');
  end if;
end;
/

declare
  l_tab_exist number;
begin
  select count(*) into l_tab_exist from 
  (select table_name from all_tables where table_name = 'PLSQL_PROFILER_UNITS' and owner = sys_context('USERENV','CURRENT_SCHEMA')
   union all
   select synonym_name from all_synonyms where synonym_name = 'PLSQL_PROFILER_UNITS' and owner = sys_context('USERENV','CURRENT_SCHEMA'));
  if l_tab_exist = 0 then
    execute immediate q'[create table plsql_profiler_units
(
  runid              number references plsql_profiler_runs,
  unit_number        number,           -- internally generated library unit #
  unit_type          varchar2(128),     -- library unit type
  unit_owner         varchar2(128),     -- library unit owner name
  unit_name          varchar2(128),     -- library unit name
  -- timestamp on library unit, can be used to detect changes to
  -- unit between runs
  unit_timestamp     date,
  total_time         number DEFAULT 0 NOT NULL,
  spare1             number,           -- unused
  spare2             number,           -- unused
  --
  primary key (runid, unit_number)
)]';
    execute immediate q'[comment on table plsql_profiler_units is
        'Information about each library unit in a run']';
    dbms_output.put_line('PLSQL_PROFILER_UNITS table created');
  end if;
end;
/

declare
  l_tab_exist number;
begin
  select count(*) into l_tab_exist from 
  (select table_name from all_tables where table_name = 'PLSQL_PROFILER_DATA' and owner = sys_context('USERENV','CURRENT_SCHEMA')
   union all
   select synonym_name from all_synonyms where synonym_name = 'PLSQL_PROFILER_DATA' and owner = sys_context('USERENV','CURRENT_SCHEMA'));
  if l_tab_exist = 0 then
    execute immediate q'[create table plsql_profiler_data
(
  runid           number,           -- unique (generated) run identifier
  unit_number     number,           -- internally generated library unit #
  line#           number not null,  -- line number in unit
  total_occur     number,           -- number of times line was executed
  total_time      number,           -- total time spent executing line
  min_time        number,           -- minimum execution time for this line
  max_time        number,           -- maximum execution time for this line
  spare1          number,           -- unused
  spare2          number,           -- unused
  spare3          number,           -- unused
  spare4          number,           -- unused
  --
  primary key (runid, unit_number, line#),
  foreign key (runid, unit_number) references plsql_profiler_units
)]';
    execute immediate q'[comment on table plsql_profiler_data is
        'Accumulated data from all profiler runs']';
    dbms_output.put_line('PLSQL_PROFILER_DATA table created');
  end if;
end;
/

declare
  l_seq_exist number;
begin
  select count(*) into l_seq_exist from 
  (select sequence_name from all_sequences where sequence_name = 'PLSQL_PROFILER_RUNNUMBER' and sequence_owner = sys_context('USERENV','CURRENT_SCHEMA')
   union all
   select synonym_name from all_synonyms where synonym_name = 'PLSQL_PROFILER_RUNNUMBER' and owner = sys_context('USERENV','CURRENT_SCHEMA'));
  if l_seq_exist = 0 then
    execute immediate q'[create sequence plsql_profiler_runnumber start with 1 nocache]';
    dbms_output.put_line('Sequence PLSQL_PROFILER_RUNNUMBER created');
  end if;
end;
/

