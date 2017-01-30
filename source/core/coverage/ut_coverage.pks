create or replace package ut_coverage authid current_user is

  -- total run coverage information
  subtype t_full_name   is varchar2(500);
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
  type tt_program_units is table of t_unit_coverage index by t_full_name;

  -- total run coverage information
  type t_coverage is record(
    covered_lines   binary_integer := 0,
    uncovered_lines binary_integer := 0,
    total_lines     binary_integer := 0,
    executions      number(38,0)   := 0,
    objects         tt_program_units
  );

  function  get_coverage_id return integer;

  function  coverage_start(a_schema_names ut_varchar2_list := ut_varchar2_list(sys_context('userenv','current_schema'))) return integer;
  procedure coverage_start(a_schema_names ut_varchar2_list := ut_varchar2_list(sys_context('userenv','current_schema')));

  /*
  * Start coverage in develop mode, where all internal calls to utPLSQL itself are also included
  */
  procedure coverage_start_develop;

  procedure coverage_stop;

  procedure coverage_pause;

  procedure coverage_resume;

  procedure coverage_flush;

  procedure skip_coverage_for(a_object ut_object_name);

  function get_coverage_data(a_coverage_id integer := null) return t_coverage;

end;
/
