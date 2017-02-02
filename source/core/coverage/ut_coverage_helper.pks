create or replace package ut_coverage_helper authid definer is

  --table of line calls indexed by line number
  -- table is sparse!!!
  type unit_line_calls is table of number(38,0) index by binary_integer;

  function  get_coverage_id return integer;
  function  is_develop_mode return boolean;

  function  coverage_start(a_run_comment varchar2) return integer;
  procedure coverage_start(a_run_comment varchar2);

  /*
  * Start coverage in develop mode, where all internal calls to utPLSQL itself are also included
  */
  procedure coverage_start_develop;

  procedure coverage_stop;

  procedure coverage_pause;

  procedure coverage_resume;

  procedure coverage_flush;

  function get_raw_coverage_data(a_object_owner varchar2, a_object_name varchar2) return unit_line_calls;
end;
/
