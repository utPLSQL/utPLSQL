create or replace package test_ut_test is

  --%suite(ut_test)
  --%suitepath(utplsql.core)

  --%beforeeach
  procedure cleanup_package_state;

  --%test(Disabled flag for a test skips the tests execution in suite)
  procedure disabled_test;

  --%test(Marks test as errored if aftertest raises exception)
  procedure aftertest_errors;

  --%test(Marks each test as errored if aftereach raises exception)
  procedure aftereach_errors;

  --%test(Marks test as errored if beforetest raises exception)
  procedure beforetest_errors;

  --%test(Marks each test as errored if beforeeach raises exception)
  procedure beforeeach_errors;


  --%context(executables in test)

  --%test(Executes aftereach procedure)
  procedure after_each_executed;

  --%test(Fails test when aftereach procedure name invalid)
  procedure after_each_proc_name_invalid;
  --%test(Tails test when aftereach procedure name null)
  procedure after_each_procedure_name_null;

  procedure create_app_info_package;
  procedure drop_app_info_package;
  --%beforetest(create_app_info_package)
  --%aftertest(drop_app_info_package)
  --%test(Sets application_info on execution of individual items)
  procedure application_info_on_execution;

  --%test(Executes beforeeach procedure)
  procedure before_each_executed;
  --%test(Fails test when beforeeach procedure name invalid)
  procedure before_each_proc_name_invalid;
  --%test(Fails test when beforeeach procedure name null)
  procedure before_each_proc_name_null;
  --%test(Does not raise exception when rollback to savepoint fails)
  procedure ignore_savepoint_exception;
  --%test(Fails when owner name invalid)
  procedure owner_name_invalid;
  --%test(Runs test as current schema when owner name null)
  procedure owner_name_null;

  procedure create_invalid_package;
  procedure drop_invalid_package;
  --%beforetest(create_app_info_package)
  --%aftertest(drop_app_info_package)
  --%test(Fails the test that references package with compilation errors)
  procedure package_in_invalid_state;
  --%test(Fails the test when package name is invalid)
  procedure package_name_invalid;
  --%test(Fails the test when package name is null)
  procedure package_name_null;
  --%test(Fails the test when procedure name invalid)
  procedure procedure_name_invalid;
  --%test(Fails the test when procedure name null)
  procedure procedure_name_null;


  --%test(Executes befroretest procedure)
  procedure before_test_executed;
  --%test(Fails test when befroretest procedure name invalid)
  procedure before_test_proc_name_invalid;
  --%test(Fails test when befroretest procedure name is null)
  procedure before_test_proc_name_null;
  --%test(Executes aftertest procedure)
  procedure after_test_executed;
  --%test(Fails test when aftertest procedure name invalid)
  procedure after_test_proce_name_invalid;
  --%test(Fails test when aftertest procedure name is null)
  procedure after_test_proc_name_null;

  procedure create_output_package;
  procedure drop_output_package;
  --%beforetest(create_output_package)
  --%aftertest(drop_output_package)
  --%test(Test output gathering)
  procedure test_output_gathering;

end;
/
