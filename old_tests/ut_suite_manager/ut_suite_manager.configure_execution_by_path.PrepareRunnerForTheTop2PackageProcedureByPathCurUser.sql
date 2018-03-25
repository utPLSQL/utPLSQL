PROMPT Prepare runner for the top 2 package procedure by path for current user

--Arrange
declare
  c_path varchar2(100) := ':tests.test_package_1.test_package_2.test2';
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
  l_test2_suite :=  treat(l_test1_suite.items(1) as ut_logical_suite);

  ut.expect(l_test2_suite.name).to_equal('test_package_2');
  ut.expect(l_test2_suite.items.count).to_equal(1);

  l_test_proc := treat(l_test2_suite.items(1) as ut_test);
  ut.expect(l_test_proc.name).to_equal('test2');
  ut.expect(l_test_proc.before_test_list.count).to_equal(1);
  ut.expect(l_test_proc.after_test_list.count).to_equal(1);

  if ut_expectation_processor.get_status = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line(q'[ut.expect(l_objects_to_run.count).to_equal(1);=]'||l_objects_to_run.count);
    dbms_output.put_line(q'[ut.expect(l_test0_suite.name).to_equal('tests');=]'||l_test0_suite.name);
    dbms_output.put_line(q'[ut.expect(l_test0_suite.items.count).to_equal(1);=]'||l_test0_suite.items.count);
    dbms_output.put_line(q'[ut.expect(l_test1_suite.name).to_equal('test_package_1');=]'||l_test1_suite.name);
    dbms_output.put_line(q'[ut.expect(l_test1_suite.items.count).to_equal(1);=]'||l_test1_suite.items.count);
    dbms_output.put_line(q'[ut.expect(l_test2_suite.name).to_equal('test_package_2');=]'||l_test2_suite.name);
    dbms_output.put_line(q'[ut.expect(l_test2_suite.items.count).to_equal(1);=]'||l_test2_suite.items.count);
    dbms_output.put_line(q'[ut.expect(l_test_proc.name).to_equal('test2');=]'||l_test_proc.name);
    dbms_output.put_line(q'[ut.expect(l_test_proc.before_test is not null).to_be_true;=]'||ut_utils.to_string(l_test_proc.before_test_list.count()));
    dbms_output.put_line(q'[ut.expect(l_test_proc.after_test is not null).to_be_true;=]'||ut_utils.to_string(l_test_proc.after_test_list.count()));
  end if;

end;
/
