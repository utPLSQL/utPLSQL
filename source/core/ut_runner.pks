create or replace package ut_runner authid definer is

  type t_call_param is record (
    ut_reporter_name   varchar2(4000) := 'ut_documentation_reporter',
    output_file_name   varchar2(4000),
    output_to_screen   varchar2(3)    := 'on',
    output_id          varchar2(4000)
  );

  type tt_call_params is table of t_call_param;

  type t_run_params is record(
    ut_paths    varchar2(4000),
    call_params tt_call_params
  );

  /**
  * Run suites/tests by path
  * Accepts value of the following formats:
  * schema - executes all suites in the schema
  * schema:suite1[.suite2] - executes all items of suite1 (suite2) in the schema.
  *                          suite1.suite2 is a suitepath variable
  * schema:suite1[.suite2][.test1] - executes test1 in suite suite1.suite2
  * schema.suite1 - executes the suite package suite1 in the schema "schema"
  *                 all the parent suites in the hiearcy setups/teardown procedures as also executed
  *                 all chile items are executed
  * schema.suite1.test2 - executes test2 procedure of suite1 suite with execution of all
  *                       parent setup/teardown procedures
  */

  procedure run(a_path varchar2 := null, a_reporter ut_reporter_base := ut_documentation_reporter());

  procedure run(a_path varchar2, a_reporters ut_reporters);

  -- TODO - implementation to be changed
  procedure run(a_paths ut_varchar2_list, a_reporter ut_reporter_base := ut_documentation_reporter());

  -- TODO - implementation to be changed
  procedure run(a_paths ut_varchar2_list, a_reporters ut_reporters);



  ----------------------------
  -- Client-side executor helper procedures and functions.

  procedure set_run_params(a_params ut_varchar2_list);

  function get_run_params return t_run_params;

  function get_streamed_output_type_name return varchar2;

end ut_runner;
/
