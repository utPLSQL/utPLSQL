create or replace package body test_before_after_annotations is
  g_tests_results clob;

  procedure create_tests_results is
    pragma autonomous_transaction;

    l_test_package_spec  varchar2(32737);
    l_test_package_body  varchar2(32737);
    l_dummy_utility_pkg_spec varchar2(32737);
    l_dummy_utility_pkg_body varchar2(32737);
    l_test_results  ut3.ut_varchar2_list;
    
    procedure drop_package(a_package_name varchar2)
    is
    begin
      execute immediate 'drop package '||a_package_name;
    end;
  begin
    l_test_package_spec := '
        create or replace package dummy_before_after_test is
            --%suite(Package to test annotations beforetest and aftertest)
            
            l_dummy_1 integer;
            l_dummy_2 integer;
            l_dummy_3 integer;
            
            --%beforeeach
            procedure clean_global_variables;

            --%test(Beforetest with call to procedure external to the test package)
            --%beforetest(dummy_utility_pkg_1.test1)
            procedure beforetest_one_ext_procedure;
            
            
            --%test(Beforetest with call to multi procedures external and interal to the test package)
            --%beforetest(dummy_utility_pkg_1.test1, test2, ut3_tester.dummy_utility_pkg_1.test3)
            procedure beforetest_multi_ext_procedure;  
            
            --%test(Beforetest with call to multi procedures where one does not exist)
            --%beforetest(dummy_utility_pkg_1.test1, non_existent_procedure, ut3_tester.dummy_utility_pkg_1.test3)
            procedure beforetest_one_err_procedure;
            
            procedure test2;
        end;
    ';

    l_test_package_body := '
        create or replace package body dummy_before_after_test is
            procedure clean_global_variables is
            begin
              l_dummy_1 := null;
              l_dummy_2 := null;
              l_dummy_3 := null;  
            end;
        
            procedure beforetest_one_ext_procedure is
            begin
              ut3.ut.expect(l_dummy_1).to_equal(1);
            end;
            
            procedure beforetest_multi_ext_procedure
            is
            begin
              ut3.ut.expect(l_dummy_1).to_equal(1);  
              ut3.ut.expect(l_dummy_2).to_equal(2);
              ut3.ut.expect(l_dummy_3).to_equal(3);
            end;
            
            procedure beforetest_one_err_procedure
            is
            begin
              null;
            end;
            
            procedure test2 is
            begin
              l_dummy_2 := 2;  
            end;
        end;
    ';
    
    l_dummy_utility_pkg_spec := '
      create or replace package dummy_utility_pkg_1 is
        procedure test1;
        
        procedure test3;
      end;
    ';
    
    l_dummy_utility_pkg_body := '
      create or replace package body dummy_utility_pkg_1 is
        procedure test1 is
        begin
          dummy_before_after_test.l_dummy_1 := 1;
        end;
        
        procedure test3 is
        begin
          dummy_before_after_test.l_dummy_3 := 3;
        end;
      end;      
    ';
    
    execute immediate l_test_package_spec;
    execute immediate l_test_package_body;
    execute immediate l_dummy_utility_pkg_spec;
    execute immediate l_dummy_utility_pkg_body;

    --Execute the tests and recolect the results
    select * bulk collect into l_test_results from table(ut3.ut.run(('dummy_before_after_test')));
    
    drop_package('dummy_utility_pkg_1');
    drop_package('dummy_before_after_test');

    g_tests_results := ut3.ut_utils.table_to_clob(l_test_results);
  end;
  
  procedure beforetest_one_ext_procedure
  is
  begin
    ut.expect(g_tests_results).to_match('^\s*Beforetest with call to procedure external to the test package \[[\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('beforetest_one_ext_procedure');
  end;
  
  procedure beforetest_multi_ext_procedure
  is
  begin
    ut.expect(g_tests_results).to_match('^\s*Beforetest with call to multi procedures external and interal to the test package \[[\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('beforetest_multi_ext_procedure');
  end;
  
  procedure beforetest_one_err_procedure
  is
  begin
    ut.expect(g_tests_results).not_to_match('^\s*Beforetest with call to multi procedures where one does not exist \[[\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).to_match('beforetest_one_err_procedure');
  end;
end;