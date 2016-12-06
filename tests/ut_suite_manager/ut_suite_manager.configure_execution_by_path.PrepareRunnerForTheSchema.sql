PROMPT Prepare runner for the schema

--Arrange
declare
  c_path           varchar2(100) := user;
  l_objects_to_run ut_objects_list;

  l_test0_suite ut_test_suite;
  l_test1_suite ut_test_suite;
  l_test2_suite ut_test_suite;
begin
  --Act
  ut_suite_manager.configure_execution_by_path(a_paths          => ut_varchar2_list(c_path)
                                              ,a_objects_to_run => l_objects_to_run);

  --Assert
  ut.expect(l_objects_to_run.count).to_equal(2);

  for i in 1 .. 2 loop
    l_test0_suite := treat(l_objects_to_run(i) as ut_test_suite);
    ut.expect(l_test0_suite.object_name in ('tests', 'tests2')).to_be_true;
    
    l_test1_suite := treat(l_test0_suite.items(1) as ut_test_suite);
  
    case l_test0_suite.object_name
      when 'tests' then
        ut.expect(l_test1_suite.object_name).to_equal('test_package_1');
        ut.expect(l_test1_suite.items.count).to_equal(3);
        l_test2_suite := treat(l_test1_suite.items(3) as ut_test_suite);
      
        ut.expect(l_test2_suite.object_name).to_equal('test_package_2');
        ut.expect(l_test2_suite.items.count).to_equal(2);
      when 'tests2' then          
        ut.expect(l_test1_suite.object_name).to_equal('test_package_3');
        ut.expect(l_test1_suite.items.count).to_equal(2);
    end case;
  
  end loop;

  if ut_assert_processor.get_aggregate_asserts_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  end if;

end;
/
