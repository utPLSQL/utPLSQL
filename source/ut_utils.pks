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
  tr_ignore                  constant number(1) := 0; -- test/suite was ignored
  tr_success                 constant number(1) := 1; -- test passed
  tr_failure                 constant number(1) := 2; -- one or more asserts failed
  tr_error                   constant number(1) := 3; -- exception was raised

  tr_ignore_char             constant varchar2(6) := 'Ignore'; -- test/suite was ignored
  tr_success_char            constant varchar2(7) := 'Success'; -- test passed
  tr_failure_char            constant varchar2(7) := 'Failure'; -- one or more asserts failed
  tr_error_char              constant varchar2(5) := 'Error'; -- exception was raised

  /*
    Constants: Rollback type for ut_test_object
  */
  gc_rollback_auto           constant number(1) := 0; -- rollback after each test and suite
  gc_rollback_manual         constant number(1) := 1; -- leave transaction control manual
  --gc_rollback_on_error       constant number(1) := 2; -- rollback tests only on error

  ex_unsopported_rollback_type exception;
  pragma exception_init(ex_unsopported_rollback_type, -20200);

  gc_max_output_string_length constant integer := 4000;
  gc_max_input_string_length  constant integer := gc_max_output_string_length - 2; --we need to remove 2 chars for quotes around string
  gc_more_data_string         constant varchar2(5) := '[...]';
  gc_overflow_substr_len      constant integer := gc_max_input_string_length - length(gc_more_data_string);
  gc_number_format            constant varchar2(100) := 'TM9';
  gc_date_format              constant varchar2(100) := 'yyyy-mm-dd"T"hh24:mi:ss';
  gc_timestamp_format         constant varchar2(100) := 'yyyy-mm-dd"T"hh24:mi:ssxff';
  gc_timestamp_tz_format      constant varchar2(100) := 'yyyy-mm-dd"T"hh24:mi:ssxff tzh:tzm';
  gc_null_string              constant varchar2(4) := 'NULL';
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

  function to_string(a_value clob) return varchar2;

  function to_string(a_value blob) return varchar2;

  function to_string(a_value boolean) return varchar2;

  function to_string(a_value number) return varchar2;

  function to_string(a_value date) return varchar2;

  function to_string(a_value timestamp_unconstrained) return varchar2;

  function to_string(a_value timestamp_tz_unconstrained) return varchar2;

  function to_string(a_value timestamp_ltz_unconstrained) return varchar2;

  function boolean_to_int(a_value boolean) return integer;

  function int_to_boolean(a_value integer) return boolean;

  /*
   Procedure: validate_rollback_type

   Validates passed value against supported rollback types
  */
  procedure validate_rollback_type(a_rollback_type number);

end ut_utils;
/
