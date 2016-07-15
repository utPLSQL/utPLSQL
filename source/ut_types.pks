create or replace package ut_types as
/* 
  Package: ut_types
   a collection of types used throught utplsql along with helper functions.

*/

/* Constants: Test Results
	tr_success - test passed
	tr_failure - one or more asserts failed
	tr_error   - exception was raised
*/
    tr_success constant number(1) :=1; -- test passed
    tr_failure constant number(1) :=2; -- one or more asserts failed
    tr_error   constant number(1) :=3; -- exception was raised
	
	/* Type: test_result 
	   a type defined to hold one of <tr_success> <tr_failure> or <tr_error>
	 */
    subtype test_result is binary_integer range 1..3;
	
	--oracle 12 types in DBMS_STANDARD. uncomment in earlier versions
	--subtype dbms_id is varchar2(30);
    --subtype dbms_quoted_id is varchar2(32);
    
/*
   Function: test_result_to_char
      returns a string representation of a test_result.

   Parameters:
        a_test_result - <test_result>.

   Returns:
      a_test_result as string.

*/
    function test_result_to_char(a_test_result test_result) return varchar2;

	/* Type: assert_result 
		property: result
		property: message
	*/
    type assert_result is record
    (
        result  test_result,
        message varchar2(4000 char)
    );
     
	/* Type: assert_list 
	 a list if assert_result.*/
    type assert_list is table of assert_result;
   
    /* Type: single_test */
    type single_test is record
    ( 
        owner_name         dbms_quoted_id,
        object_name        dbms_quoted_id,  
        setup_procedure    dbms_quoted_id,
        teardown_procedure dbms_quoted_id,
        test_procedure     dbms_quoted_id
    );
    function single_test_is_valid(a_single_test in out nocopy single_test) return boolean;
    function single_test_setup_stmt(a_single_test in single_test) return varchar2;
    function single_test_teardown_stmt(a_single_test in single_test) return varchar2;
    function single_test_test_stmt(a_single_test in single_test) return varchar2;
    
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

    Function Test_Suite_Reporter_Is_Valid(A_Test_Suite_Reporter In Out Nocopy Test_Suite_Reporter) Return Boolean;
    function test_suite_reporter_bs_stmt(a_test_suite_reporter in test_suite_reporter) return varchar2;
    function test_suite_reporter_es_stmt(a_test_suite_reporter in test_suite_reporter) return varchar2;
    function test_suite_reporter_bt_stmt(a_test_suite_reporter in test_suite_reporter) return varchar2;
    function test_suite_reporter_et_stmt(a_test_suite_reporter in test_suite_reporter) return varchar2;

    
end ut_types;