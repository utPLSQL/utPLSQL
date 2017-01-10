create or replace package body ut_coverage_reporter_helper is

  function table_exists(a_table_name varchar2) return boolean is
    l_count integer;
  begin
    select count(1) into l_count from user_tables where table_name = a_table_name;
    return l_count = 1;
  end;

  function sequence_exists(a_sequence_name varchar2) return boolean is
    l_count integer;
  begin
    select count(1) into l_count from user_sequences where sequence_name = a_sequence_name;
    return l_count = 1;
  end;

  procedure check_and_create_objects is
  begin
    if not sequence_exists('PLSQL_PROFILER_RUNNUMBER') then
      execute immediate 'create sequence plsql_profiler_runnumber start with 1 nocache';
    end if;
    if not table_exists('PLSQL_PROFILER_RUNS') then
      execute immediate 'create table plsql_profiler_runs
        (
          runid           number primary key,  -- unique run identifier,
                                               -- from plsql_profiler_runnumber
          related_run     number,              -- runid of related run (for client/
                                               --     server correlation)
          run_owner       varchar2(32),        -- user who started run
          run_date        date,                -- start time of run
          run_comment     varchar2(2047),      -- user provided comment for this run
          run_total_time  number,              -- elapsed time for this run
          run_system_info varchar2(2047),      -- currently unused
          run_comment1    varchar2(2047),      -- additional comment
          spare1          varchar2(256)        -- unused
        )';
    end if;
    if not table_exists('PLSQL_PROFILER_UNITS') then
      execute immediate 'create table plsql_profiler_units
        (
          runid              number references plsql_profiler_runs,
          unit_number        number,           -- internally generated library unit #
          unit_type          varchar2(32),     -- library unit type
          unit_owner         varchar2(32),     -- library unit owner name
          unit_name          varchar2(32),     -- library unit name
          -- timestamp on library unit, can be used to detect changes to
          -- unit between runs
          unit_timestamp     date,
          total_time         number DEFAULT 0 NOT NULL,
          spare1             number,           -- unused
          spare2             number,           -- unused
          --
          primary key (runid, unit_number)
        )';
    end if;
    if not table_exists('PLSQL_PROFILER_DATA') then
      execute immediate 'create table plsql_profiler_data
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
        )';
    end if;
  end;

  function profiler_start(a_run_comment varchar2 := ut_utils.to_string(systimestamp) ) return binary_integer is
    l_run_number  binary_integer;
  begin
    dbms_profiler.start_profiler(run_comment => a_run_comment, run_number => l_run_number);
    return l_run_number;
  end;

  procedure profiler_flush is
      l_return_code binary_integer;
    l_run_number  binary_integer;
  begin
    l_return_code := dbms_profiler.flush_data();
  end;

  procedure profiler_pause is
    l_return_code binary_integer;
  begin
    l_return_code := dbms_profiler.pause_profiler();
  end;

  procedure profiler_resume is
    l_return_code binary_integer;
  begin
    l_return_code := dbms_profiler.resume_profiler();
  end;

  procedure profiler_stop is
    l_return_code binary_integer;
  begin
    l_return_code := dbms_profiler.stop_profiler();
  end;

-- -- details query
-- with coverage_source as(
--       select
--         u.unit_owner,
--         u.unit_name,
--         u.unit_type,
--         s.line as line_number,
--         d.total_occur,
--         --skip procedure / function definition line as it is sometimes reported with 0 coverage, even if it was called
--         case when
--           regexp_instr(s.text, '^\s*(((not)?(overriding|final|instantiable))*\s*(procedure|function)|end\s*;)', 1, 1, 0,
--                        'i') = 0
--           then
--             case when d.total_occur > 0
--               then 1
--             else d.total_occur end
--         end       is_covered,
--         s.text as line_text
--       from plsql_profiler_units u
--         join all_source s
--           on s.owner = u.unit_owner
--              and s.name = u.unit_name
--         left join plsql_profiler_data d
--           on u.runid = d.runid
--              and u.unit_number = d.unit_number
--              and s.line = d.line#
--       where u.runid = 7
--             and s.type not in ('PACKAGE', 'TYPE')
--             and u.unit_type not in ('PACKAGE SPEC', 'TYPE SPEC')
--     ),
--     coverage_filtered as(
--       select
--         unit_owner,
--         unit_name,
--         unit_type,
--         line_number,
--         total_occur,
--         case
--           when regexp_instr(
--                    line_text,
--                    '^\s*(((not)?(overriding|final|instantiable))*\s*(procedure|function)|end\s*;)',
--                    1, 1, 0, 'i'
--                ) = 0
--           then
--             case when total_occur > 0 then 1 else total_occur end
--          end is_covered,
--          line_text
--       from coverage_source
--   ),
--   coverage_calculated as (
--     select
--       unit_owner,
--       unit_name,
--       unit_type,
--       line_number,
--       total_occur,
--       case is_covered when 1 then 'Y' when 0 then 'N' else NULL end is_covered,
--       line_text
--     from coverage_filtered
--   )
-- select
--   unit_owner, unit_name, unit_type, line_number, is_covered, line_text
-- from coverage_calculated
-- order by unit_owner, unit_name, unit_type, line_number
--
-- --totals query
-- with coverage_source as(
--       select
--         u.unit_owner,
--         u.unit_name,
--         u.unit_type,
--         s.line as line_number,
--         d.total_occur,
--         --skip procedure / function definition line as it is sometimes reported with 0 coverage, even if it was called
--         case when
--           regexp_instr(s.text, '^\s*(((not)?(overriding|final|instantiable))*\s*(procedure|function)|end\s*;)', 1, 1, 0,
--                        'i') = 0
--           then
--             case when d.total_occur > 0
--               then 1
--             else d.total_occur end
--         end       is_covered,
--         s.text as line_text
--       from plsql_profiler_units u
--         join all_source s
--           on s.owner = u.unit_owner
--              and s.name = u.unit_name
--         left join plsql_profiler_data d
--           on u.runid = d.runid
--              and u.unit_number = d.unit_number
--              and s.line = d.line#
--       where u.runid = 7
--             and s.type not in ('PACKAGE', 'TYPE')
--             and u.unit_type not in ('PACKAGE SPEC', 'TYPE SPEC')
--     ),
--     coverage_filtered as(
--       select
--         unit_owner,
--         unit_name,
--         unit_type,
--         line_number,
--         total_occur,
--         case
--           when regexp_instr(
--                    line_text,
--                    '^\s*(((not)?(overriding|final|instantiable))*\s*(procedure|function)|end\s*;)',
--                    1, 1, 0, 'i'
--                ) = 0
--           then
--             case when total_occur > 0 then 1 else total_occur end
--          end is_covered,
--          line_text
--       from coverage_source
--   )
-- select
--   unit_owner, unit_name,
--   count(1) lines_count,
--   count(is_covered) coverable_lines_count,
--   sum(is_covered) covered_lines_count,
--   round(sum(is_covered) * 100 / count(is_covered),2) as coverage
-- from coverage_filtered
-- group by rollup(unit_owner, unit_name)
-- order by unit_owner, unit_name;

end;
/
