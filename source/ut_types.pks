create or replace package ut_types as

    tr_success constant number(1) :=1; -- test passed
    tr_failure constant number(1) :=2; -- one or more asserts failed
    tr_error   constant number(1) :=3; -- exception was raised    
    subtype test_result is binary_integer range 1..3;
    
    function test_result_to_char(a_test_result test_result) return varchar2;

    type assert_result is record
    (
        result test_result,
        message varchar2(4000)
    );
     
    type assert_list is table of assert_result;
   
    type single_test is record
    ( 
	    owner_name varchar2(30),
        object_name varchar2(30),  
        setup_procedure varchar2(30),
        teardown_procedure varchar2(30),
        test_procedure varchar2(30)
    );
    
    type test_execution_result is record
    (
        test single_test,
        start_time timestamp,
        end_time timestamp,
        result test_result,
        assert_results assert_list 
    );
    
    type test_list is table of single_test;
	
    type test_suite is record
    ( 
      suite_name varchar2(50),
      tests test_list	  
	  
    );
    
    -- may want to this be a record that contains this list.
    -- not really sure yet.
    type test_suite_results is table of test_execution_result;
    
    
    type test_suite_reporter is record
    (
	  owner_name varchar2(30),
      package_name varchar2(30),
      begin_suite_procedure varchar2(30) not null default 'begin_suite',
      end_suite_procedure  varchar2(30) not null default 'end_suite',
      begin_test_procedure varchar2(30) not null default 'begin_test',
      end_test_procedure varchar2(30) not null default 'end_test' 
    );
    
    type test_suite_reporters is table of test_suite_reporter;
    
end ut_types;