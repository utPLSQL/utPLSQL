create or replace package ut_runner_helper authid definer is

  type t_call_param is record (
    ut_reporter_name   varchar2(4000) := 'ut_documentation_reporter',
    output_file_name   varchar2(4000),
    output_to_screen   varchar2(3)    := 'on',
    reporter_id        raw(32)
  );

  type tt_call_params is table of t_call_param;

  type t_run_params is record(
    ut_paths      varchar2(4000),
    color_enabled boolean,
    call_params   tt_call_params
  );

  ----------------------------
  -- Client-side executor helper procedures and functions.

  procedure set_run_params(a_params ut_varchar2_list);

  function get_run_params return t_run_params;

  function get_streamed_output_type_name return varchar2;

end ut_runner_helper;
/
