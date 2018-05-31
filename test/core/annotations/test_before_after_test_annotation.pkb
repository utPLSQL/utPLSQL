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
    l_dummy_utility_pkg_spec := '
      create or replace package dummy_utility_pkg_1 is
        g_executed_procedures ut_varchar2_list;
        g_test4_executed boolean := false;
        g_test5_executed boolean := false;
        g_beforetest_one_err_procedure boolean := false;
        
        procedure insert_executed_procedure(a_procedure_name varchar2);
      
        procedure test1;
        
        procedure test3;
        
        procedure test4;
        
        procedure test5;
      end;
    ';
    
    l_dummy_utility_pkg_body := '
      create or replace package body dummy_utility_pkg_1 is
        procedure insert_executed_procedure(a_procedure_name varchar2)
        is
        begin
          if g_executed_procedures is null then
            g_executed_procedures :=  ut_varchar2_list(a_procedure_name);
          else
            g_executed_procedures.extend;
            g_executed_procedures(g_executed_procedures.count) := a_procedure_name;
          end if;
        end;
        
        procedure test1 is
        begin
          insert_executed_procedure(''test1'');
        end;
        
        procedure test3 is
        begin
          insert_executed_procedure(''test3'');
        end;
        
        procedure test4 is
        begin
          g_test4_executed := true;
        end;
        
        procedure test5 is
        begin
          g_test4_executed := true;
        end;
      end;      
    ';
  
    l_test_package_spec := '
        create or replace package dummy_before_after_test is
            --%suite(Package to test annotations beforetest and aftertest)
            
            --%aftereach
            procedure clean_global_variables;

            --%test(Beforetest with call to procedure external to the test package)
            --%beforetest(dummy_utility_pkg_1.test1)
            procedure beforetest_one_ext_procedure;
            
            
            --%test(Beforetest with call to multi procedures external and interal to the test package)
            --%beforetest(dummy_utility_pkg_1.test1, test2, ut3_tester.dummy_utility_pkg_1.test3)
            procedure beforetest_multi_ext_procedure;  
            
            --%test(Beforetest with call to multi procedures where one does not exist)
            --%beforetest(dummy_utility_pkg_1.test4, non_existent_procedure, ut3_tester.dummy_utility_pkg_1.test5)
            procedure beforetest_one_err_procedure;
            
            --%test(Test which beforetest procedures were executed)
            procedure test_executed_beforetests;
            
            procedure test2;
        end;
    ';

    l_test_package_body := '
        create or replace package body dummy_before_after_test is
            procedure clean_global_variables is
            begin
              dummy_utility_pkg_1.g_executed_procedures := null;
            end;
        
            procedure beforetest_one_ext_procedure is
            begin
              ut3.ut.expect(dummy_utility_pkg_1.g_executed_procedures(1)).to_equal(''test1'');
            end;
            
            procedure beforetest_multi_ext_procedure
            is
            begin
              ut3.ut.expect(dummy_utility_pkg_1.g_executed_procedures(1)).to_equal(''test1'');
              ut3.ut.expect(dummy_utility_pkg_1.g_executed_procedures(2)).to_equal(''test2'');
              ut3.ut.expect(dummy_utility_pkg_1.g_executed_procedures(3)).to_equal(''test3'');
            end;
            
            procedure beforetest_one_err_procedure
            is
            begin
              dummy_utility_pkg_1.g_beforetest_one_err_procedure := true;
            end;
            
            procedure test_executed_beforetests
            is
            begin
              ut3.ut.expect(dummy_utility_pkg_1.g_test4_executed).to_be_true;
              ut3.ut.expect(dummy_utility_pkg_1.g_test5_executed).to_be_false;
              ut3.ut.expect(dummy_utility_pkg_1.g_beforetest_one_err_procedure).to_be_false;
            end;
            
            procedure test2 is
            begin
              dummy_utility_pkg_1.insert_executed_procedure(''test2'');
            end;
        end;
    ';
    
    execute immediate l_dummy_utility_pkg_spec;
    execute immediate l_dummy_utility_pkg_body;
    execute immediate l_test_package_spec;
    execute immediate l_test_package_body;

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
    --Also test the execution order of the beforetest procedures
    ut.expect(g_tests_results).to_match('^\s*Beforetest with call to multi procedures external and interal to the test package \[[\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('beforetest_multi_ext_procedure');
  end;
  
  procedure beforetest_one_err_procedure
  is
  begin
    ut.expect(g_tests_results).to_match('^\s*Call params for before_test are not valid: procedure does not exist\s*[^.]+\.DUMMY_BEFORE_AFTER_TEST\.NON_EXISTENT_PROCEDURE\s*$', 'm');
    ut.expect(g_tests_results).not_to_match('^\s*Beforetest with call to multi procedures where one does not exist \[[\.0-9]+ sec\]\s*$','m');
  end;
  
  procedure test_executed_beforetests
  is
  begin
    ut.expect(g_tests_results).to_match('^\s*Test which beforetest procedures were executed \[[\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('test_executed_beforetests');
  end;
end;
/