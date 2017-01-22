create or replace package ut_coverage is

  gc_missed   constant varchar2(7) := 'missed';
  gc_skipped  constant varchar2(7) := 'skipped';
  gc_covered  constant varchar2(7) := 'covered';

  subtype t_schema_name is varchar2(250);
  subtype t_object_name is varchar2(250);

  type t_line_info is record(
    status     varchar2(7),
    executions binary_integer,
    covered    boolean
  );
  -- line coverage information indexed by line no.
  type tt_lines is table of t_line_info index by binary_integer;
  --unit coverage information record
  type t_unit_coverage is record (
    covered_lines   binary_integer := 0,
    uncovered_lines binary_integer := 0,
    total_lines     binary_integer := 0,
    executions      number(38,0) := 0,
    lines           tt_lines
  );
  -- coverage information indexed by object name
  type tt_program_units is table of t_unit_coverage index by t_object_name;
  type t_schema_coverage is record (
    covered_lines   binary_integer := 0,
    uncovered_lines binary_integer := 0,
    total_lines     binary_integer := 0,
    executions      number(38,0) := 0,
    units           tt_program_units
  );
  -- coverage information for schema indexed by schema name
  type tt_schemes is table of t_schema_coverage index by t_schema_name;

  -- total run coverage information
  type t_coverage is record(
    covered_lines   binary_integer := 0,
    uncovered_lines binary_integer := 0,
    total_lines     binary_integer := 0,
    executions      number(38,0)   := 0,
    objects         binary_integer := 0,
    schemes         tt_schemes
  );

  function profiler_start(a_run_comment varchar2 := ut_utils.to_string(systimestamp) ) return binary_integer;
  procedure profiler_flush;
  procedure profiler_pause;
  procedure profiler_resume;
  procedure profiler_stop;

  function get_coverage_data(a_run_id integer) return t_coverage;

end;
/
