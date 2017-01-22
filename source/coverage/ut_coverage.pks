create or replace package ut_coverage is

  subtype t_schema_name is varchar2(250);
  subtype t_object_name is varchar2(250);

  subtype t_line_executions is binary_integer;
  -- line coverage information indexed by line no.
  type tt_lines is table of t_line_executions index by binary_integer;
  --unit coverage information record
  type t_unit_coverage is record (
    covered_lines   binary_integer := 0,
    uncovered_lines binary_integer := 0,
    total_lines     binary_integer := 0,
    executions      number(38,0) := 0,
    lines           tt_lines
  );
  -- coverage information indexed by full object name (schema.object)
  type tt_program_units is table of t_unit_coverage index by t_object_name;

  -- total run coverage information
  type t_coverage is record(
    covered_lines   binary_integer := 0,
    uncovered_lines binary_integer := 0,
    total_lines     binary_integer := 0,
    executions      number(38,0)   := 0,
    objects         tt_program_units
  );

  function profiler_start(a_run_comment varchar2 := ut_utils.to_string(systimestamp) ) return binary_integer;
  procedure profiler_start(a_run_comment varchar2 := ut_utils.to_string(systimestamp) );
  procedure profiler_flush;
  procedure profiler_pause;
  procedure profiler_resume;
  procedure profiler_stop;

  function get_coverage_data(a_run_id integer) return t_coverage;

end;
/
