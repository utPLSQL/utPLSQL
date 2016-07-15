create or replace package body ut_test_execute 
as

  
  procedure execute_procedure(a_owner_name in varchar2
                              ,a_package_name in varchar2
                              ,a_procedure_name in varchar2)
  as
    obj_data user_objects%rowtype;
    stmt varchar2(104);
    execute_stmt boolean := true; 
  begin
    $if $$ut_trace $then dbms_output.put_line('ut_execute.execute_procedure'); $end
  
    if execute_stmt then 
        stmt := 'begin ' || trim(a_owner_name) || trim(a_package_name) || '.' || trim(a_procedure_name) || '; end;';
        $if $$ut_trace $then dbms_output.put_line('execute_procedure stmt:' || stmt); $end
        execute immediate stmt;
    end if;    
  end;
   
  procedure execute_package_test(a_test_to_execute in ut_types.single_test)
  as
  begin
    $if $$ut_trace $then dbms_output.put_line('executepackagetest ' || a_test_to_execute.owner_name || '.' || a_test_to_execute.object_name || '.' || a_test_to_execute.test_procedure); $end
    
    if not ut_metadata.package_valid(a_test_to_execute.owner_name,a_test_to_execute.object_name) then
       ut_assert.report_error('package does not exist or is invalid: ' || nvl(a_test_to_execute.object_name,'<missing package name>'));
       return;
    end if;
    
    if not ut_metadata.procedure_exists(a_test_to_execute.owner_name,a_test_to_execute.object_name,a_test_to_execute.setup_procedure) then
       ut_assert.report_error('package missing setup method ' || a_test_to_execute.object_name || '.' || nvl(a_test_to_execute.setup_procedure,'<missing procedure name>'));
       return;
    end if;     

    if not ut_metadata.procedure_exists(a_test_to_execute.owner_name,a_test_to_execute.object_name,a_test_to_execute.test_procedure) then
       ut_assert.report_error('package missing test method ' || a_test_to_execute.object_name || '.' || nvl(a_test_to_execute.test_procedure,'<missing procedure name>'));
       return;
    end if;     

    if not ut_metadata.procedure_exists(a_test_to_execute.owner_name,a_test_to_execute.object_name,a_test_to_execute.teardown_procedure) then
       ut_assert.report_error('package missing teardown method ' || a_test_to_execute.object_name || '.' || nvl(a_test_to_execute.teardown_procedure,'<missing procedure name>'));
       return;
    end if;     


        
    execute_procedure(a_test_to_execute.owner_name,a_test_to_execute.object_name,a_test_to_execute.setup_procedure);
    begin
       execute_procedure(a_test_to_execute.owner_name,a_test_to_execute.object_name,a_test_to_execute.test_procedure);
    exception
      when others then
        -- dbms_utility.format_error_backtrace is 10g or later
        -- utl_call_stack package may be better but it's 12c but still need to investigate
        -- article with details: http://www.oracle.com/technetwork/issue-archive/2014/14-jan/o14plsql-2045346.html
       $if $$ut_trace $then dbms_output.put_line('testmethod failed-' ||sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_backtrace); $end        
       ut_assert.report_error(sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_backtrace);
    end;
    execute_procedure(a_test_to_execute.owner_name,a_test_to_execute.object_name,a_test_to_execute.teardown_procedure);
  end execute_package_test;
  
  
  procedure execute_test (a_test_to_execute in ut_types.single_test,
                         a_test_result    out ut_types.test_execution_result)                        
                         
  as
  begin     
    $if $$ut_trace $then dbms_output.put_line('ut_execute.execute_test'); $end         
    a_test_result.test := a_test_to_execute;
    a_test_result.start_time := current_timestamp;
    execute_package_test(a_test_to_execute);
    a_test_result.end_time := current_timestamp;
    a_test_result.assert_results := ut_types.assert_list();
    ut_assert.copy_called_asserts(a_test_result.assert_results);
    a_test_result.result := ut_assert.current_assert_test_result;
    ut_assert.clear_asserts;    
            
  exception
     when others then
     begin
        $if $$ut_trace $then dbms_output.put_line('execute_test failed-' ||sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_backtrace); $end
        -- most likely occured in setup or teardown if here.
        ut_assert.report_error(sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_stack); 
        ut_assert.report_error(sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_backtrace); 
        ut_assert.copy_called_asserts(a_test_result.assert_results);
        ut_assert.clear_asserts;
        a_test_result.result := ut_types.tr_error;
     end;   
        
  end execute_test;
end ut_test_execute;
/