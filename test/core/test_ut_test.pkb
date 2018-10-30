create or replace package body test_ut_test is

  procedure cleanup_package_state is
  begin
    ut_example_tests.g_number := null;
  end;

  procedure disabled_test is
    l_suite    ut3.ut_suite;
    l_test     ut3.ut_test;
  begin
    --Arrange
    l_suite := ut3.ut_suite(a_object_owner => USER, a_object_name => 'UT_EXAMPLE_TESTS', a_line_no=> 1);
    l_suite.path := 'ut_example_tests';
    l_suite.before_all_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_EXAMPLE_TESTS', 'set_g_number_0', ut3.ut_utils.gc_before_all));

    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number', a_line_no=> 1));
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number', a_line_no=> 2));
    l_suite.items(l_suite.items.last).disabled_flag := ut3.ut_utils.boolean_to_int(true);
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(ut_example_tests.g_number).to_equal(1);
    ut.expect(l_suite.result).to_equal(ut3.ut_utils.gc_success);
    ut.expect(l_suite.results_count.disabled_count).to_equal(1);
    ut.expect(l_suite.results_count.warnings_count).to_equal(0);
    ut.expect(l_suite.results_count.success_count).to_equal(1);
    ut.expect(l_suite.results_count.failure_count).to_equal(0);
    ut.expect(l_suite.results_count.errored_count).to_equal(0);
  end;

  procedure aftertest_errors is
    l_suite    ut3.ut_suite;
    l_test     ut3.ut_test;
  begin
    --Arrange
    l_suite := ut3.ut_suite(a_object_owner => USER, a_object_name => 'UT_EXAMPLE_TESTS', a_line_no=> 1);
    l_suite.path := 'ut_example_tests';
    l_suite.before_all_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_EXAMPLE_TESTS', 'set_g_number_0', ut3.ut_utils.gc_before_all));

    l_test := ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number', a_line_no=> 1);
    l_test.before_test_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_EXAMPLE_TESTS', 'add_1_to_g_number', ut3.ut_utils.gc_before_test));
    l_test.after_test_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_EXAMPLE_TESTS', 'failing_procedure', ut3.ut_utils.gc_after_test));
    l_suite.add_item(l_test);
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number', a_line_no=> 1));
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(ut_example_tests.g_number).to_equal(3);
    ut.expect(l_suite.result).to_equal(ut3.ut_utils.gc_error);
    ut.expect(l_suite.results_count.disabled_count).to_equal(0);
    ut.expect(l_suite.results_count.warnings_count).to_equal(0);
    ut.expect(l_suite.results_count.success_count).to_equal(1);
    ut.expect(l_suite.results_count.failure_count).to_equal(0);
    ut.expect(l_suite.results_count.errored_count).to_equal(1);
  end;

  procedure aftereach_errors is
    l_suite    ut3.ut_suite;
    l_test     ut3.ut_test;
  begin
    --Arrange
    l_suite := ut3.ut_suite(a_object_owner => USER, a_object_name => 'UT_EXAMPLE_TESTS', a_line_no=> 1);
    l_suite.before_all_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_EXAMPLE_TESTS', 'set_g_number_0', ut3.ut_utils.gc_before_all));
    l_test := ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number', a_line_no=> 1);
    l_test.before_each_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_EXAMPLE_TESTS', 'add_1_to_g_number', ut3.ut_utils.gc_before_each));
    l_test.after_each_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_EXAMPLE_TESTS', 'failing_procedure', ut3.ut_utils.gc_after_each));
    l_suite.add_item(l_test);
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number', a_line_no=> 1));
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(ut_example_tests.g_number).to_equal(3);
    ut.expect(l_suite.result).to_equal(ut3.ut_utils.gc_error);
    ut.expect(l_suite.results_count.disabled_count).to_equal(0);
    ut.expect(l_suite.results_count.warnings_count).to_equal(0);
    ut.expect(l_suite.results_count.success_count).to_equal(1);
    ut.expect(l_suite.results_count.failure_count).to_equal(0);
    ut.expect(l_suite.results_count.errored_count).to_equal(1);
  end;

  procedure beforetest_errors is
    l_suite    ut3.ut_suite;
    l_test     ut3.ut_test;
  begin
    --Arrange
    l_suite := ut3.ut_suite(a_object_owner => USER, a_object_name => 'UT_EXAMPLE_TESTS', a_line_no=> 1);
    l_suite.before_all_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_EXAMPLE_TESTS', 'set_g_number_0', ut3.ut_utils.gc_before_all));
    l_test := ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number', a_line_no=> 1);
    l_test.before_test_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_EXAMPLE_TESTS', 'failing_procedure', ut3.ut_utils.gc_before_test));
    l_test.after_test_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_EXAMPLE_TESTS', 'add_1_to_g_number', ut3.ut_utils.gc_after_test));
    l_suite.add_item(l_test);
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number', a_line_no=> 1));
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(ut_example_tests.g_number).to_equal(2);
    ut.expect(l_suite.result).to_equal(ut3.ut_utils.gc_error);
    ut.expect(l_suite.results_count.disabled_count).to_equal(0);
    ut.expect(l_suite.results_count.warnings_count).to_equal(0);
    ut.expect(l_suite.results_count.success_count).to_equal(1);
    ut.expect(l_suite.results_count.failure_count).to_equal(0);
    ut.expect(l_suite.results_count.errored_count).to_equal(1);
  end;

  procedure beforeeach_errors is
    l_suite    ut3.ut_suite;
    l_test     ut3.ut_test;
  begin
    --Arrange
    l_suite := ut3.ut_suite(a_object_owner => USER, a_object_name => 'UT_EXAMPLE_TESTS', a_line_no=> 1);
    l_suite.before_all_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_EXAMPLE_TESTS', 'set_g_number_0', ut3.ut_utils.gc_before_all));
    l_test := ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number', a_line_no=> 1);
    l_test.before_each_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_EXAMPLE_TESTS', 'failing_procedure', ut3.ut_utils.gc_before_each));
    l_test.after_each_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_EXAMPLE_TESTS', 'add_1_to_g_number', ut3.ut_utils.gc_after_each));
    l_suite.add_item(l_test);
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number', a_line_no=> 1));
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(ut_example_tests.g_number).to_equal(2);
    ut.expect(l_suite.result).to_equal(ut3.ut_utils.gc_error);
    ut.expect(l_suite.results_count.disabled_count).to_equal(0);
    ut.expect(l_suite.results_count.warnings_count).to_equal(0);
    ut.expect(l_suite.results_count.success_count).to_equal(1);
    ut.expect(l_suite.results_count.failure_count).to_equal(0);
    ut.expect(l_suite.results_count.errored_count).to_equal(1);
  end;

end;
/
