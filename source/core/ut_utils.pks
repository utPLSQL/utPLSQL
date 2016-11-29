create or replace package ut_utils authid definer is

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


  /*
   Function: string_to_table

     Parameters:
          a_string - the text to be split.
          a_delimiter - the delimiter character or string
          a_skip_leading_delimiter - determines if the leading delimiter should be ignored, used by clob_to_table

     Returns:
        ut_varchar2_list - table of string

   Splits a given string into table of string by delimiter.
   The delimiter gets removed.
   If null passed as any of the parameters, empty table is returned.
   If no occurence of a_delimiter found in a_text then text is returned as a single row of the table.
   If no text between delimiters found then an empty row is returned, example:
     string_to_table( 'a,,b', ',' ) gives table ut_varchar2_list( 'a', null, 'b' );
  */
  function string_to_table(a_string varchar2, a_delimiter varchar2:= chr(10), a_skip_leading_delimiter varchar2 := 'N') return ut_varchar2_list;

  /*
   Function: clob_to_table

     Parameters:
          a_clob - the text to be split.
          a_delimiter - the delimiter character or string (default chr(10) )
          a_max_amount - the maximum length of returned string (default 32767)

     Returns:
        ut_varchar2_list - table of string

   Splits a given string into table of string by delimiter.
   The delimiter gets removed.
   If null passed as any of the parameters, empty table is returned.
   If split text is longer than a_max_amount it gets split into pieces of a_max_amount.
   If no text between delimiters found then an empty row is returned, example:
     string_to_table( 'a,,b', ',' ) gives table ut_varchar2_list( 'a', null, 'b' );
  */
  function clob_to_table(a_clob clob, a_max_amount integer := 32767, a_delimiter varchar2:= chr(10)) return ut_varchar2_list;

  function table_to_clob(a_text_table ut_varchar2_list) return clob;

end ut_utils;
/
