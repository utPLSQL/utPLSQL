create or replace package test_ut_suite is

  --%suite(ut_suite)
  --%suitepath(utplsql.ut3_tester.core)

  --%beforeeach
  procedure cleanup_package_state;

  --%test(Disabled flag skips tests execution in suite)
  procedure disabled_suite;

  --%test(Marks each test as errored if beforeall raises exception)
  procedure beforeall_errors;

  --%test(Reports warnings for each test if afterall raises exception)
  procedure aftereall_errors;

  --%beforetest(ut3_tester_helper.run_helper.package_no_body)
  --%aftertest(ut3_tester_helper.run_helper.drop_package_no_body)
  --%test(Fails all tests in package when package has no body)
  procedure package_without_body;

  --%test(Fails all tests in package when package body is invalid)
  procedure package_with_invalid_body;

  --%context( rollback_test )
  
  --%beforeall
  procedure create_trans_control;
  --%afterall
  procedure drop_trans_control;
  
  --%test(Performs automatic rollback after a suite)
  procedure rollback_auto;

  --%test(Performs automatic rollback after a suite even if test fails)
  procedure rollback_auto_on_failure;

  --%test(rollback(manual) - disables automatic rollback after a suite)
  procedure rollback_manual;

  --%test(rollback(manual) - disables automatic rollback after a suite even if test fails)
  procedure rollback_manual_on_failure;
 
  --%endcontext
  
  --%test(Transaction invalidators list is trimmed in warnings when too long)
  procedure trim_transaction_invalidators;

end;
/
