declare
  l_tab_exist number;
begin
  select count(*) into l_tab_exist from
    (select table_name from all_tables where table_name = 'DBMSPCC_BLOCKS' and owner = sys_context('USERENV','CURRENT_SCHEMA')
      union all
     select synonym_name from all_synonyms where synonym_name = 'DBMSPCC_BLOCKS' and owner = sys_context('USERENV','CURRENT_SCHEMA'));
  if l_tab_exist = 0 then
    execute immediate q'[
      create global temporary table dbmspcc_blocks (
        run_id         number(38, 0),
        object_id      number(38, 0),
        block          number(38, 0),
        line           number(38, 0) constraint dbmspcc_blocks_line_nn not null enable,
        col            number(38, 0) constraint dbmspcc_blocks_col_nn not null enable,
        covered        number(1, 0) constraint dbmspcc_blocks_covered_nn not null enable,
        not_feasible   number(1, 0) constraint dbmspcc_blocks_not_feasible_nn not null enable,
        constraint dbmspcc_blocks_block_ck check ( block >= 0 ) enable,
        constraint dbmspcc_blocks_line_ck check ( line >= 0 ) enable,
        constraint dbmspcc_blocks_col_ck check ( col >= 0 ) enable,
        constraint dbmspcc_blocks_covered_ck check ( covered in ( 0, 1 ) ) enable,
        constraint dbmspcc_blocks_not_feasible_ck check ( not_feasible in ( 0, 1 ) ) enable,
        constraint dbmspcc_blocks_pk primary key ( run_id, object_id, block ) using index
      ) on commit preserve rows]';
  end if;
end;
/
declare
  l_tab_exist number;
begin
  select count(*) into l_tab_exist from
    (select table_name from all_tables where table_name = 'DBMSPCC_RUNS' and owner = sys_context('USERENV','CURRENT_SCHEMA')
      union all
     select synonym_name from all_synonyms where synonym_name = 'DBMSPCC_RUNS' and owner = sys_context('USERENV','CURRENT_SCHEMA'));
  if l_tab_exist = 0 then
    execute immediate q'[
      create global temporary table dbmspcc_runs (
        run_id          number(38, 0),
        run_comment     varchar2(4000 byte),
        run_owner       varchar2(128 byte) constraint dbmspcc_runs_run_owner_nn not null enable,
        run_timestamp   date constraint dbmspcc_runs_run_timestamp_nn not null enable,
        constraint dbmspcc_runs_pk primary key ( run_id ) using index enable
      ) on commit preserve rows]';
    end if;
end;
/
declare
  l_tab_exist number;
begin
  select count(*) into l_tab_exist from
    (select table_name from all_tables where table_name = 'DBMSPCC_UNITS' and owner = sys_context('USERENV','CURRENT_SCHEMA')
      union all
     select synonym_name from all_synonyms where synonym_name = 'DBMSPCC_UNITS' and owner = sys_context('USERENV','CURRENT_SCHEMA'));
  if l_tab_exist = 0 then
    execute immediate q'[
      create global temporary table dbmspcc_units (
        run_id          number(38, 0),
        object_id       number(38, 0),
        owner           varchar2(128 byte) constraint dbmspcc_units_owner_nn not null enable,
        name            varchar2(128 byte) constraint dbmspcc_units_name_nn not null enable,
        type            varchar2(12 byte) constraint dbmspcc_units_type_nn not null enable,
        last_ddl_time   date constraint dbmspcc_units_last_ddl_time_nn not null enable,
        constraint dbmspcc_units_pk primary key ( run_id, object_id ) using index enable
      ) on commit preserve rows]';
  end if;
end;
/
