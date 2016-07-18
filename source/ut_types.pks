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
  tr_success     constant number(1) := 1; -- test passed
  tr_failure     constant number(1) := 2; -- one or more asserts failed
  tr_error       constant number(1) := 3; -- exception was raised
	tr_not_valid   constant number(1) := 4; -- exception was raised

  /* Type: test_result
    a type defined to hold one of <tr_success> <tr_failure> or <tr_error>
  */
  --subtype test_result is number range 1..3;

  --oracle 12 types in DBMS_STANDARD. uncomment in earlier versions
  --$if sys.dbms_db_version.version = 11 $then
  --subtype dbms_id is varchar2(30);
  --subtype dbms_quoted_id is varchar2(32);
  --$end

  /*
     Function: test_result_to_char
        returns a string representation of a test_result.
  
     Parameters:
          a_test_result - <test_result>.
  
     Returns:
        a_test_result as string.
  
  */
  function test_result_to_char(a_test_result integer) return varchar2;

end ut_types;
/
