declare
  l_tab_exist number;
begin
  select count(*) into l_tab_exist
    from all_tables
   where table_name = 'UT_COVERAGE_RUNS' and owner = sys_context('USERENV','CURRENT_SCHEMA');
  if l_tab_exist = 0 then
    execute immediate q'[create table ut_coverage_runs
    (
      coverage_run_id      raw(32) not null,
      line_coverage_id     number(38,0) unique not null,
      block_coverage_id    number(38,0) unique,
      constraint ut_coverage_runs primary key (coverage_run_id, line_coverage_id)
    ) organization index ]';
    execute immediate q'[comment on table ut_coverage_runs is
      'Map of block and line coverage runs for a test-run']';
    dbms_output.put_line('UT_COVERAGE_RUNS table created');
  end if;
end;
/
