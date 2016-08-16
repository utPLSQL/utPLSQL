create or replace package ut_utils is

  /*
    Package: ut_utils
     a collection of tools used throught utplsql along with helper functions.
  
  */

  /* Constants: Test Results
    tr_success - test passed
    tr_failure - one or more asserts failed
    tr_error   - exception was raised
  */
  tr_success          constant number(1) := 1; -- test passed
  tr_failure          constant number(1) := 2; -- one or more asserts failed
  tr_error            constant number(1) := 3; -- exception was raised

  tr_success_char     constant varchar2(7) := 'Success'; -- test passed
  tr_failure_char     constant varchar2(7) := 'Failure'; -- one or more asserts failed
  tr_error_char       constant varchar2(5) := 'Error'; -- exception was raised
  /*
     Function: test_result_to_char
        returns a string representation of a test_result.
  
     Parameters:
          a_test_result - <test_result>.
  
     Returns:
        a_test_result as string.
  
  */
  function test_result_to_char(a_test_result integer) return varchar2;

  procedure debug_log(a_message varchar2);

end ut_utils;
/
