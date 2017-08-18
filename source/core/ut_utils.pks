create or replace package ut_utils authid definer is
  /*
  utPLSQL - Version X.X.X.X
  Copyright 2016 - 2017 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  /*
    Package: ut_utils
     a collection of tools used throught utplsql along with helper functions.

  */

  gc_version                 constant varchar2(50) := 'utPLSQL - Version X.X.X.X';

  /* Constants: Event names */
  gc_run                     constant varchar2(12) := 'run';
  gc_suite                   constant varchar2(12) := 'suite';
  gc_before_all              constant varchar2(12) := 'before_all';
  gc_before_each             constant varchar2(12) := 'before_each';
  gc_before_test             constant varchar2(12) := 'before_test';
  gc_test                    constant varchar2(12) := 'test';
  gc_test_execute            constant varchar2(12) := 'test_execute';
  gc_after_test              constant varchar2(10) := 'after_test';
  gc_after_each              constant varchar2(12) := 'after_each';
  gc_after_all               constant varchar2(12) := 'after_all';
  gc_finalize                constant varchar2(12) := 'finalize';

  /* Constants: Test Results */
  tr_disabled                constant number(1) := 0; -- test/suite was disabled
  tr_success                 constant number(1) := 1; -- test passed
  tr_failure                 constant number(1) := 2; -- one or more expectations failed
  tr_error                   constant number(1) := 3; -- exception was raised

  tr_disabled_char           constant varchar2(8) := 'Disabled'; -- test/suite was disabled
  tr_success_char            constant varchar2(7) := 'Success'; -- test passed
  tr_failure_char            constant varchar2(7) := 'Failure'; -- one or more expectations failed
  tr_error_char              constant varchar2(5) := 'Error'; -- exception was raised

  /*
    Constants: Rollback type for ut_test_object
  */
  gc_rollback_auto           constant number(1) := 0; -- rollback after each test and suite
  gc_rollback_manual         constant number(1) := 1; -- leave transaction control manual
  --gc_rollback_on_error       constant number(1) := 2; -- rollback tests only on error

  ex_unsupported_rollback_type exception;
  gc_unsupported_rollback_type constant pls_integer := -20200;
  pragma exception_init(ex_unsupported_rollback_type, -20200);

  ex_path_list_is_empty exception;
  gc_path_list_is_empty constant pls_integer := -20201;
  pragma exception_init(ex_path_list_is_empty, -20201);

  ex_invalid_path_format exception;
  gc_invalid_path_format constant pls_integer := -20202;
  pragma exception_init(ex_invalid_path_format, -20202);

  ex_suite_package_not_found exception;
  gc_suite_package_not_found constant pls_integer := -20204;
  pragma exception_init(ex_suite_package_not_found, -20204);

  -- Reporting event time not supported
  ex_invalid_rep_event_time exception;
  gc_invalid_rep_event_time constant pls_integer := -20210;
  pragma exception_init(ex_invalid_rep_event_time, -20210);

  -- Reporting event name not supported
  ex_invalid_rep_event_name exception;
  gc_invalid_rep_event_name constant pls_integer := -20211;
  pragma exception_init(ex_invalid_rep_event_name, -20211);

  -- Any of tests failed
  ex_some_tests_failed exception;
  gc_some_tests_failed constant pls_integer := -20213;
  pragma exception_init(ex_some_tests_failed, -20213);


  gc_max_storage_varchar2_len constant integer := 4000;
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
  procedure debug_log(a_message clob);

  function to_string(a_value varchar2, a_qoute_char varchar2 := '''') return varchar2;

  function to_string(a_value clob, a_qoute_char varchar2 := '''') return varchar2;

  function to_string(a_value blob, a_qoute_char varchar2 := '''') return varchar2;

  function to_string(a_value boolean) return varchar2;

  function to_string(a_value number) return varchar2;

  function to_string(a_value date) return varchar2;

  function to_string(a_value timestamp_unconstrained) return varchar2;

  function to_string(a_value timestamp_tz_unconstrained) return varchar2;

  function to_string(a_value timestamp_ltz_unconstrained) return varchar2;

  function to_string(a_value yminterval_unconstrained) return varchar2;

  function to_string(a_value dsinterval_unconstrained) return varchar2;

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
          a_max_amount - the maximum length of returned string (default 8191)

     Returns:
        ut_varchar2_list - table of string

   Splits a given string into table of string by delimiter.
   Default value of a_max_amount is 8191 because of code can contains multibyte character.
   The delimiter gets removed.
   If null passed as any of the parameters, empty table is returned.
   If split text is longer than a_max_amount it gets split into pieces of a_max_amount.
   If no text between delimiters found then an empty row is returned, example:
     string_to_table( 'a,,b', ',' ) gives table ut_varchar2_list( 'a', null, 'b' );
  */
  function clob_to_table(a_clob clob, a_max_amount integer := 8191, a_delimiter varchar2:= chr(10)) return ut_varchar2_list;

  function table_to_clob(a_text_table ut_varchar2_list, a_delimiter varchar2:= chr(10)) return clob;

  /*
    Returns time difference in seconds (with miliseconds) between given timestamps
  */
  function time_diff(a_start_time timestamp with time zone, a_end_time timestamp with time zone) return number;

  /*
  * Returns a text indented with spaces except the first line.
  */
  function indent_lines(a_text varchar2, a_indent_size integer := 4, a_include_first_line boolean := false) return varchar2;


  /*
  * Returns a list of object that are part of utPLSQL framework
  */
  function get_utplsql_objects_list return ut_object_names;

  /*
  * Append a line to the end of ut_varchar2_lst
  */
  procedure append_to_varchar2_list(a_list in out nocopy ut_varchar2_list, a_line varchar2);

  procedure append_to_clob(a_src_clob in out nocopy clob, a_new_data clob);
  procedure append_to_clob(a_src_clob in out nocopy clob, a_new_data varchar2);

  function convert_collection(a_collection ut_varchar2_list) return ut_varchar2_rows;
  
  /**
  * Set session's action and module using dbms_application_info
  */
  procedure set_action(a_text in varchar2);
  
  /**
  * Set session's client info using dbms_application_info
  */
  procedure set_client_info(a_text in varchar2);

  function to_xpath(a_list varchar2, a_ancestors varchar2 := '/*/') return varchar2;

  function to_xpath(a_list ut_varchar2_list, a_ancestors varchar2 := '/*/') return varchar2;

  procedure cleanup_temp_tables;

end ut_utils;
/
