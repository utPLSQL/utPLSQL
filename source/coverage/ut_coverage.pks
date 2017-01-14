create or replace package ut_coverage is

  subtype t_schema_name is varchar2(250);
  subtype t_object_name is varchar2(250);

  subtype t_line_covered is boolean;
  -- line coverage information indexed by line no:
  -- true  -> line was covered
  -- false -> line was relevant but not covered
  -- missing lines are considered not relevant (comments etc)
  type tt_unit_coverage is table of t_line_covered index by binary_integer;
  -- coverage information indexed by object name
  type tt_schema_coverage is table of tt_unit_coverage index by t_object_name;
  -- coverage information for objects indexed by schema name
  type tt_coverage is table of tt_schema_coverage index by t_schema_name;

  function profiler_start(a_run_comment varchar2 := ut_utils.to_string(systimestamp) ) return binary_integer;
  procedure profiler_flush;
  procedure profiler_pause;
  procedure profiler_resume;
  procedure profiler_stop;

  function get_coverage_data(a_run_id integer) return tt_coverage;

end;
/
