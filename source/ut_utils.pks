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
  tr_success                 constant number(1) := 1; -- test passed
  tr_failure                 constant number(1) := 2; -- one or more asserts failed
  tr_error                   constant number(1) := 3; -- exception was raised

  tr_success_char            constant varchar2(7) := 'Success'; -- test passed
  tr_failure_char            constant varchar2(7) := 'Failure'; -- one or more asserts failed
  tr_error_char              constant varchar2(5) := 'Error'; -- exception was raised
  
  /*
    Constants: Rollback type for ut_test_object
  */
  gc_rollback_auto           constant number(1) := 0; -- rollback after each test and suite
  gc_rollback_manual         constant number(1) := 1; -- leave transaction control manual
  --gc_rollback_on_error       constant number(1) := 2; -- rollback tests only on error


  gc_max_sring_length        constant integer := 4000;
  gc_more_data_string        constant varchar2(5) := '[...]';
  gc_overflow_substr_len     constant integer := gc_max_sring_length - length(gc_more_data_string);
  gc_number_format           constant varchar2(100) := 'TM9';
  gc_date_format             constant varchar2(100) := 'yyyy-mm-dd hh24:mi:ss';
  gc_timestamp_format        constant varchar2(100) := 'yyyy-mm-dd hh24:mi:ssxff';
  /*
     Function: test_result_to_char
        returns a string representation of a test_result.
  
     Parameters:
          a_test_result - <test_result>.
  
     Returns:
        a_test_result as string.
  
  */
  function test_result_to_char(a_test_result integer) return varchar2;

  function to_test_result(a_test boolean) return integer;
  
  function gen_savepoint_name return varchar2;

  procedure debug_log(a_message varchar2);

  function to_string(a_value varchar2) return varchar2;

  function to_string(a_value boolean) return varchar2;

  function to_string(a_value number) return varchar2;

  function to_string(a_value date) return varchar2;

  function to_string(a_value timestamp_unconstrained) return varchar2;

end ut_utils;
/
