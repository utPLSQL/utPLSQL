create or replace package ut_coverage_reporter_helper is

  procedure check_and_create_objects;
  function profiler_start(a_run_comment varchar2 := ut_utils.to_string(systimestamp) ) return binary_integer;
  procedure profiler_flush;
  procedure profiler_pause;
  procedure profiler_resume;
  procedure profiler_stop;

end;
/
