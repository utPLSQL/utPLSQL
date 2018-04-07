create or replace package body test_ut_test is

  procedure cleanup_package_state is
  begin
    ut_example_tests.g_number := null;
  end;

  procedure disabled_test is
    l_suite    ut3.ut_logical_suite;
    l_listener ut3.ut_event_listener := ut3.ut_event_listener(ut3.ut_reporters());
  begin
    --Arrange
    l_suite := ut3.ut_suite(
        a_name => 'UT_EXAMPLE_TESTS',
        a_object_name => 'UT_EXAMPLE_TESTS',
        a_path => 'ut_example_tests',
        a_before_all_proc_name => 'set_g_number_0'
    );
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number'));
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number',a_disabled_flag => true));
    --Act
    l_suite.do_execute(l_listener);
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
    l_suite    ut3.ut_logical_suite;
    l_listener ut3.ut_event_listener := ut3.ut_event_listener(ut3.ut_reporters());
  begin
    --Arrange
    l_suite := ut3.ut_suite(
        a_name => 'UT_EXAMPLE_TESTS',
        a_object_name => 'UT_EXAMPLE_TESTS',
        a_path => 'ut_example_tests',
        a_before_all_proc_name => 'set_g_number_0'
    );
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number', a_before_test_proc_name=>'add_1_to_g_number', a_after_test_proc_name=>'failing_procedure'));
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number'));
    --Act
    l_suite.do_execute(l_listener);
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
    l_suite    ut3.ut_logical_suite;
    l_listener ut3.ut_event_listener := ut3.ut_event_listener(ut3.ut_reporters());
  begin
    --Arrange
    l_suite := ut3.ut_suite(
        a_name => 'UT_EXAMPLE_TESTS',
        a_object_name => 'UT_EXAMPLE_TESTS',
        a_path => 'ut_example_tests',
        a_before_all_proc_name => 'set_g_number_0'
    );
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number', a_before_each_proc_name=>'add_1_to_g_number', a_after_each_proc_name=>'failing_procedure'));
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number'));
    --Act
    l_suite.do_execute(l_listener);
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
    l_suite    ut3.ut_logical_suite;
    l_listener ut3.ut_event_listener := ut3.ut_event_listener(ut3.ut_reporters());
  begin
    --Arrange
    l_suite := ut3.ut_suite(
        a_name => 'UT_EXAMPLE_TESTS',
        a_object_name => 'UT_EXAMPLE_TESTS',
        a_path => 'ut_example_tests',
        a_before_all_proc_name => 'set_g_number_0'
    );
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number', a_before_test_proc_name=>'failing_procedure', a_after_test_proc_name=>'add_1_to_g_number'));
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number'));
    --Act
    l_suite.do_execute(l_listener);
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
    l_suite    ut3.ut_logical_suite;
    l_listener ut3.ut_event_listener := ut3.ut_event_listener(ut3.ut_reporters());
  begin
    --Arrange
    l_suite := ut3.ut_suite(
        a_name => 'UT_EXAMPLE_TESTS',
        a_object_name => 'UT_EXAMPLE_TESTS',
        a_path => 'ut_example_tests',
        a_before_all_proc_name => 'set_g_number_0'
    );
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number', a_before_each_proc_name=>'failing_procedure', a_after_each_proc_name=>'add_1_to_g_number'));
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number'));
    --Act
    l_suite.do_execute(l_listener);
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
