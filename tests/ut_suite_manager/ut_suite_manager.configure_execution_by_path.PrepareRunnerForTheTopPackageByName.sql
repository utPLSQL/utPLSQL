PROMPT Prepare runner for the top package by package name

--Arrange
declare
  c_path varchar2(100) := USER||'.test_package_1';
  l_objects_to_run ut_suite_items;
  
  l_test0_suite ut_logical_suite;
  l_test1_suite ut_suite;
  l_test2_suite ut_suite;
begin  
--Act
  l_objects_to_run := ut_suite_manager.configure_execution_by_path(ut_varchar2_list(c_path));
  
--Assert
  ut.expect(l_objects_to_run.count).to_equal(1);
  l_test0_suite := treat(l_objects_to_run(1) as ut_logical_suite);
  
  ut.expect(l_test0_suite.name).to_equal('tests');
  ut.expect(l_test0_suite.items.count).to_equal(1);
  l_test1_suite :=  treat(l_test0_suite.items(1) as ut_suite);
  
  ut.expect(l_test1_suite.name).to_equal('test_package_1');
  ut.expect(l_test1_suite.items.count).to_equal(3);
  ut.expect(l_test1_suite.before_each is not null).to_be_true;
  
  ut.expect(l_test1_suite.items(1).name).to_equal('test1');
  ut.expect(l_test1_suite.items(1).description).to_equal('Test1 from test package 1');
  ut.expect(treat(l_test1_suite.items(1) as ut_test).before_test.is_defined).to_be_false;
  ut.expect(treat(l_test1_suite.items(1) as ut_test).after_test.is_defined).to_be_false;
  ut.expect(treat(l_test1_suite.items(1) as ut_test).ignore_flag).to_equal(0);
  
  ut.expect(l_test1_suite.items(2).name).to_equal('test2');
  ut.expect(l_test1_suite.items(2).description).to_equal('Test2 from test package 1');
  ut.expect(treat(l_test1_suite.items(2) as ut_test).before_test.is_defined).to_be_true;
  ut.expect(treat(l_test1_suite.items(2) as ut_test).after_test.is_defined).to_be_true;
  ut.expect(treat(l_test1_suite.items(2) as ut_test).ignore_flag).to_equal(0);
  
  -- temporary behavior.
  -- decided that when executed by package, not path, only that package has to execute
  l_test2_suite :=  treat(l_test1_suite.items(3) as ut_suite);
  
  ut.expect(l_test2_suite.name).to_equal('test_package_2');
  ut.expect(l_test2_suite.items.count).to_equal(2);

  
  if ut_assert_processor.get_aggregate_asserts_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    declare
      l_results ut_assert_results;
    begin
      l_results := ut_assert_processor.get_asserts_results;
      for i in 1..l_results.count loop
        if l_results(i).result > ut_utils.tr_success then
          dbms_output.put_line(l_results(i).get_result_clob);
        end if;
      end loop;
    end;

  end if;

end;
/
