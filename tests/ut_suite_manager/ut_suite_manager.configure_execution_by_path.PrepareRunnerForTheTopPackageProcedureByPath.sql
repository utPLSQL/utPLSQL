PROMPT Prepare runner for the top package procedure by path

--Arrange
declare
  c_path varchar2(100) := USER||':tests.test_package_1.test2';
  l_objects_to_run ut_suite_items;

  l_test0_suite ut_logical_suite;
  l_test1_suite ut_logical_suite;
  l_test2_suite ut_logical_suite;
  l_test_proc ut_test;
begin
--Act
  l_objects_to_run := ut_suite_manager.configure_execution_by_path(ut_varchar2_list(c_path));

--Assert
  ut.expect(l_objects_to_run.count).to_equal(1);
  l_test0_suite := treat(l_objects_to_run(1) as ut_logical_suite);

  ut.expect(l_test0_suite.name).to_equal('tests');
  ut.expect(l_test0_suite.items.count).to_equal(1);
  l_test1_suite :=  treat(l_test0_suite.items(1) as ut_logical_suite);

  ut.expect(l_test1_suite.name).to_equal('test_package_1');
  ut.expect(l_test1_suite.items.count).to_equal(1);
  l_test_proc := treat(l_test1_suite.items(1) as ut_test);

  ut.expect(l_test_proc.name).to_equal('test2');
  ut.expect(l_test_proc.description).to_equal('Test2 from test package 1');
  ut.expect(l_test_proc.before_test is not null).to_be_true;
  ut.expect(l_test_proc.after_test is not null).to_be_true;

  if ut_expectation_processor.get_aggregate_asserts_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  end if;

end;
/
