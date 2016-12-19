create or replace package ut_runner authid definer is

  procedure run(a_path in varchar2, a_reporter in ut_reporter);

  -- implementation to be changed
  procedure run(a_paths in ut_varchar2_list, a_reporter in ut_reporter);



  ----------------------------
  -- SQLPlus executor helper procedures and functions.

  --returns a text to be executed by sqlplus in order to make all the script call parameters optional
  --@param a_params_count - determines the number of parameters to be made optional (default is 100)
  function get_optional_params_script(a_params_count integer := 100) return ut_varchar2_list pipelined;

  procedure set_call_params(a_params ut_varchar2_list);

  function get_run_in_background_script return ut_varchar2_list pipelined;

  function get_outputs_script return ut_varchar2_list pipelined;

end ut_runner;
/
