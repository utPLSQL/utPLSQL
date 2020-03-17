create or replace package body test_ut_suite is

  procedure cleanup_package_state is
  begin
    ut3_tester_helper.ut_example_tests.g_number := null;
  end;
  
  procedure create_trans_control is
  begin
    ut3_tester_helper.run_helper.create_trans_control;
  end;
  
  procedure drop_trans_control is
  begin
    ut3_tester_helper.run_helper.drop_trans_control;
  end;
  
  procedure disabled_suite is
    l_suite    ut3_develop.ut_suite;
  begin
    --Arrange
    l_suite := ut3_develop.ut_suite(a_object_owner => 'ut3_tester_helper', a_object_name => 'UT_EXAMPLE_TESTS', a_line_no=> 1);
    l_suite.path := 'ut3_tester_helper.ut_example_tests';
    l_suite.disabled_flag := ut3_develop.ut_utils.boolean_to_int(true);
    l_suite.before_all_list := ut3_develop.ut_executables(ut3_develop.ut_executable('ut3_tester_helper', 'UT_EXAMPLE_TESTS', 'set_g_number_0', ut3_develop.ut_utils.gc_before_all));
    l_suite.after_all_list := ut3_develop.ut_executables(ut3_develop.ut_executable('ut3_tester_helper', 'UT_EXAMPLE_TESTS', 'add_1_to_g_number', ut3_develop.ut_utils.gc_before_all));
    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := ut3_develop.ut_test(a_object_owner => 'ut3_tester_helper', a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number', a_line_no=> 1);
    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := ut3_develop.ut_test(a_object_owner => 'ut3_tester_helper', a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number', a_line_no=> 1);
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_be_null;
    ut.expect(l_suite.result).to_equal(ut3_develop.ut_utils.gc_disabled);
    ut.expect(l_suite.results_count.disabled_count).to_equal(2);
    ut.expect(l_suite.results_count.warnings_count).to_equal(0);
    ut.expect(l_suite.results_count.success_count).to_equal(0);
    ut.expect(l_suite.results_count.failure_count).to_equal(0);
    ut.expect(l_suite.results_count.errored_count).to_equal(0);
  end;

  procedure beforeall_errors is
    l_suite    ut3_develop.ut_suite;
  begin
    --Arrange
    l_suite := ut3_develop.ut_suite(a_object_owner => 'ut3_tester_helper', a_object_name => 'UT_EXAMPLE_TESTS', a_line_no=> 1);
    l_suite.path := 'ut3_tester_helper.ut_example_tests';
    l_suite.before_all_list := ut3_develop.ut_executables(ut3_develop.ut_executable('ut3_tester_helper', 'UT_EXAMPLE_TESTS', 'failing_procedure', ut3_develop.ut_utils.gc_before_all));
    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := ut3_develop.ut_test(a_object_owner => 'ut3_tester_helper',a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'set_g_number_0', a_line_no=> 1);
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_be_null;
    ut.expect(l_suite.result).to_equal(ut3_develop.ut_utils.gc_error);
    ut.expect(l_suite.results_count.disabled_count).to_equal(0);
    ut.expect(l_suite.results_count.warnings_count).to_equal(0);
    ut.expect(l_suite.results_count.success_count).to_equal(0);
    ut.expect(l_suite.results_count.failure_count).to_equal(0);
    ut.expect(l_suite.results_count.errored_count).to_equal(1);
  end;

  procedure aftereall_errors is
    l_suite    ut3_develop.ut_suite;
  begin
    --Arrange
    l_suite := ut3_develop.ut_suite(a_object_owner => 'ut3_tester_helper', a_object_name => 'UT_EXAMPLE_TESTS', a_line_no=> 1);
    l_suite.path := 'ut3_tester_helper.ut_example_tests';
    l_suite.after_all_list := ut3_develop.ut_executables(ut3_develop.ut_executable('ut3_tester_helper', 'UT_EXAMPLE_TESTS', 'failing_procedure', ut3_develop.ut_utils.gc_after_all));

    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := ut3_develop.ut_test(a_object_owner => 'ut3_tester_helper', a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'set_g_number_0', a_line_no=> 1);
    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := ut3_develop.ut_test(a_object_owner => 'ut3_tester_helper', a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number', a_line_no=> 1);
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_equal(1);
    ut.expect(l_suite.result).to_equal(ut3_develop.ut_utils.gc_success);
    ut.expect(l_suite.results_count.disabled_count).to_equal(0);
    ut.expect(l_suite.results_count.warnings_count).to_equal(1);
    ut.expect(l_suite.results_count.success_count).to_equal(2);
    ut.expect(l_suite.results_count.failure_count).to_equal(0);
    ut.expect(l_suite.results_count.errored_count).to_equal(0);
  end;

  procedure package_without_body is
    l_suite    ut3_develop.ut_suite;
  begin
    l_suite := ut3_develop.ut_suite(a_object_owner => USER, a_object_name => 'UT_WITHOUT_BODY', a_line_no=> 1);
    l_suite.path := 'UT_WITHOUT_BODY';
    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := ut3_develop.ut_test(a_object_name => 'ut_without_body',a_name => 'test1', a_line_no=> 1);
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(l_suite.result).to_equal(ut3_develop.ut_utils.gc_error);
  end;

  procedure package_with_invalid_body is
    l_suite    ut3_develop.ut_suite;
  begin
    l_suite := ut3_develop.ut_suite(a_object_owner => USER, a_object_name => 'UT_WITH_INVALID_BODY', a_line_no=> 1);
    l_suite.path := 'UT_WITH_INVALID_BODY';
    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := ut3_develop.ut_test(a_object_name => 'ut_with_invalid_body',a_name => 'test1', a_line_no=> 1);
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(l_suite.result).to_equal(ut3_develop.ut_utils.gc_error);
  end;

  procedure rollback_auto is
    l_suite    ut3_develop.ut_suite;
  begin
    --Arrange
    execute immediate 'delete from ut3_tester_helper.ut$test_table';
    l_suite := ut3_develop.ut_suite(a_object_owner => USER, a_object_name => 'UT_TRANSACTION_CONTROL', a_line_no=> 1);
    l_suite.path := 'ut3_tester_helper.ut_transaction_control';
    l_suite.before_all_list := ut3_develop.ut_executables(ut3_develop.ut_executable(USER, 'UT_TRANSACTION_CONTROL', 'setup', ut3_develop.ut_utils.gc_before_all));
    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := ut3_develop.ut_test(a_object_owner => USER, a_object_name => 'ut_transaction_control',a_name => 'test', a_line_no=> 1);
    l_suite.set_rollback_type(ut3_develop.ut_utils.gc_rollback_auto);

    --Act
    l_suite.do_execute();

    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_value(q'[ut3_tester_helper.ut_transaction_control.count_rows('t')]')).to_equal(0);
    ut.expect(ut3_tester_helper.main_helper.get_value(q'[ut3_tester_helper.ut_transaction_control.count_rows('s')]')).to_equal(0);
  end;

  procedure rollback_auto_on_failure is
  begin
    ut3_tester_helper.run_helper.test_rollback_type('test_failure', ut3_develop.ut_utils.gc_rollback_auto, equal(0) );
  end;

  procedure rollback_manual is
  begin
    ut3_tester_helper.run_helper.test_rollback_type('test', ut3_develop.ut_utils.gc_rollback_manual, be_greater_than(0) );
  end;

  procedure rollback_manual_on_failure is
  begin
    ut3_tester_helper.run_helper.test_rollback_type('test_failure', ut3_develop.ut_utils.gc_rollback_manual, be_greater_than(0) );
  end;

  procedure trim_transaction_invalidators is
    l_suite ut3_develop.ut_suite;
  begin
    --arrange
    l_suite := ut3_develop.ut_suite(a_object_owner => USER, a_object_name => 'UT_EXAMPLE_TESTS', a_line_no=> 1);
    for i in 1 .. 100 loop
      l_suite.add_transaction_invalidator('schema_name.package_name.procedure_name'||i);
    end loop;
    --Act
    l_suite.rollback_to_savepoint('dummy_savepoint');
    --Assert
    ut.expect(l_suite.warnings.count).to_equal(1);
  end;

end;
/