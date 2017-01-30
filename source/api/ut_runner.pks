create or replace package ut_runner authid current_user is

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

  procedure run(a_path varchar2 := null, a_reporter ut_reporter_base := ut_documentation_reporter(), a_color_console boolean := false);

  procedure run(a_path varchar2, a_reporters ut_reporters, a_color_console boolean := false);

  -- TODO - implementation to be changed
  procedure run(a_paths ut_varchar2_list, a_reporter ut_reporter_base := ut_documentation_reporter(), a_color_console boolean := false);

  -- TODO - implementation to be changed
  procedure run(a_paths ut_varchar2_list, a_reporters ut_reporters, a_color_console boolean := false);

end ut_runner;
/
