create or replace package ut_coverage_reporter_helper is

  subtype t_schema_name is varchar2(250);
  subtype t_object_name is varchar2(250);

  subtype t_line_covered is binary_integer range 0 .. 1;
  -- line coverage information indexed by line no:
  -- 1 -> line was covered
  -- 0 -> line was relevant but not covered
  -- missing lines are considered not relevant (comments etc)
  type tt_unit_coverage is table of t_line_covered index by binary_integer;
  -- coverage information indexed by object name
  type tt_schema_coverage is table of tt_unit_coverage index by t_object_name;
  -- coverage information for objects indexed by schema name
  type tt_coverage is table of tt_schema_coverage index by t_schema_name;

  procedure check_and_create_objects;
  function profiler_start(a_run_comment varchar2 := ut_utils.to_string(systimestamp) ) return binary_integer;
  procedure profiler_flush;
  procedure profiler_pause;
  procedure profiler_resume;
  procedure profiler_stop;

  procedure gather_coverage_data(a_run_id integer);

  function get_coverage_data(a_run_id integer) return tt_coverage;

  function get_static_file_names return ut_varchar2_list;

  function get_static_file(a_file_name varchar2) return clob;

  function get_details_file_content(a_object_owner varchar2, a_object_name varchar2) return clob;

end;
/
