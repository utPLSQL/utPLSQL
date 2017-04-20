PROMPT Prepare runner for the top package without subsuites by path

--Arrange
declare
  c_path varchar2(100) := USER||':tests2.test_package_3';
  l_objects_to_run ut_suite_items;

  l_test0_suite ut_logical_suite;
  l_test1_suite ut_logical_suite;
  l_test1        ut_test;
  l_test3        ut_test;
begin
--Act
  l_objects_to_run := ut_suite_manager.configure_execution_by_path(ut_varchar2_list(c_path));

--Assert
  ut.expect(l_objects_to_run.count).to_equal(1);
  l_test0_suite := treat(l_objects_to_run(1) as ut_logical_suite);

  ut.expect(l_test0_suite.name).to_equal('tests2');
  ut.expect(l_test0_suite.items.count).to_equal(1);
  l_test1_suite :=  treat(l_test0_suite.items(1) as ut_logical_suite);

  ut.expect(l_test1_suite.name).to_equal('test_package_3');
  ut.expect(l_test1_suite.items.count).to_equal(3);

  l_test1 := treat(l_test1_suite.items(1) as ut_test);
  ut.expect(l_test1.name).to_equal('test1');
  ut.expect(l_test1.disabled_flag).to_equal(0);

  l_test3 := treat(l_test1_suite.items(3) as ut_test);
  ut.expect(l_test3.name).to_equal('disabled_test');
  ut.expect(l_test3.disabled_flag).to_equal(1);

  if ut_expectation_processor.get_aggregate_asserts_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  end if;

end;
/
