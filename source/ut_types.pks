create or replace package ut_types as

    tr_success constant number(1) :=1; -- test passed
    tr_failure constant number(1) :=2; -- one or more asserts failed
    tr_error   constant number(1) :=3; -- exception was raised    
    subtype test_result is binary_integer range 1..3;
	
	--oracle 12 types in DBMS_STANDARD. uncomment in earlier versions
	--subtype dbms_id is varchar2(30);
    --subtype dbms_quoted_id is varchar2(32);
    
    function test_result_to_char(a_test_result test_result) return varchar2;


    type assert_result is record
    (
        result  test_result,
        message varchar2(4000 char)
    );
     
    type assert_list is table of assert_result;
   
    type single_test is record
    ( 
	    owner_name         dbms_quoted_id,
        object_name        dbms_quoted_id,  
        setup_procedure    dbms_quoted_id,
        teardown_procedure dbms_quoted_id,
        test_procedure     dbms_quoted_id
    );
    function single_test_is_valid(a_single_test IN OUT NOCOPY single_test) return boolean;
    
    type test_execution_result is record
    (
        test           single_test,
        start_time     timestamp with time zone,
        end_time       timestamp with time zone,
        result         test_result,
        assert_results assert_list 
    );
    
    type test_list is table of single_test;

    type test_suite is record
    ( 
      suite_name varchar2(50 char),
      tests      test_list
    );
    
    -- may want to this be a record that contains this list.
    -- not really sure yet.
    type test_suite_results is table of test_execution_result;
    
    
    type test_suite_reporter is record
    (
	  owner_name            dbms_quoted_id,
      package_name          dbms_quoted_id,
      begin_suite_procedure dbms_quoted_id not null default 'begin_suite',
      end_suite_procedure   dbms_quoted_id not null default 'end_suite',
      begin_test_procedure  dbms_quoted_id not null default 'begin_test',
      end_test_procedure    dbms_quoted_id not null default 'end_test' 
    );
    
    type test_suite_reporters is table of test_suite_reporter;
    
end ut_types;