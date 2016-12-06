PROMPT Prepare runner for the top 2 package by package name

--Arrange
declare
  c_path varchar2(100) := USER||'.test_package_2';
  l_objects_to_run ut_objects_list;
  
  l_test0_suite ut_test_suite;
  l_test1_suite ut_test_suite;
  l_test2_suite ut_test_suite;
begin  
--Act
  ut_suite_manager.configure_execution_by_path(a_paths => ut_varchar2_list(c_path), a_objects_to_run => l_objects_to_run);
  
--Assert
  ut.expect(l_objects_to_run.count).to_equal(1);
  l_test0_suite := treat(l_objects_to_run(1) as ut_test_suite);
  
  ut.expect(l_test0_suite.object_name).to_equal('tests');
  ut.expect(l_test0_suite.items.count).to_equal(1);
  l_test1_suite :=  treat(l_test0_suite.items(1) as ut_test_suite);   
  
  ut.expect(l_test1_suite.object_name).to_equal('test_package_1');  
  ut.expect(l_test1_suite.items.count).to_equal(1);
  l_test2_suite :=  treat(l_test1_suite.items(1) as ut_test_suite);   
  
  ut.expect(l_test2_suite.object_name).to_equal('test_package_2');
  ut.expect(l_test2_suite.items.count).to_equal(2);

  
  if ut_assert_processor.get_aggregate_asserts_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  end if;

end;
/
