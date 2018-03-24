create or replace package ut_utils authid definer is
  /*
  utPLSQL - Version 3
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

  /**
   * Common utilities and constants used throughout utPLSQL framework
   *
   */

  gc_version                 constant varchar2(50) := 'v3.1.0.1693-develop';

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

  -- Any of tests failed
  ex_invalid_version_no exception;
  gc_invalid_version_no constant pls_integer := -20214;
  pragma exception_init(ex_invalid_version_no, -20214);

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

  type t_version is record(
    major  natural,
    minor  natural,
    bugfix natural,
    build  natural
  );

  type t_clob_tab is table of clob;

  /**
   * Converts test results into strings
   *
   * @param a_test_result numeric representation of test result
   *
   * @return a string representation of a test_result.
   */
  function test_result_to_char(a_test_result integer) return varchar2;

  function to_test_result(a_test boolean) return integer;

  /**
   * Generates a unique name for a savepoint
   * Uses sys_guid, as timestamp gives only miliseconds on Windows and is not unique
   * Issue: #506 for details on the implementation approach
   */
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

  /**
   * Validates passed value against supported rollback types
   */
  procedure validate_rollback_type(a_rollback_type number);


  /**
   *
   * Splits a given string into table of string by delimiter.
   * The delimiter gets removed.
   * If null passed as any of the parameters, empty table is returned.
   * If no occurence of a_delimiter found in a_text then text is returned as a single row of the table.
   * If no text between delimiters found then an empty row is returned, example:
   *   string_to_table( 'a,,b', ',' ) gives table ut_varchar2_list( 'a', null, 'b' );
   *
   * @param a_string                 the text to be split.
   * @param a_delimiter              the delimiter character or string
   * @param a_skip_leading_delimiter determines if the leading delimiter should be ignored, used by clob_to_table
   *
   * @return table of varchar2 values
   */
  function string_to_table(a_string varchar2, a_delimiter varchar2:= chr(10), a_skip_leading_delimiter varchar2 := 'N') return ut_varchar2_list;

  /**
   * Splits a given string into table of string by delimiter.
   * Default value of a_max_amount is 8191 because of code can contains multibyte character.
   * The delimiter gets removed.
   * If null passed as any of the parameters, empty table is returned.
   * If split text is longer than a_max_amount it gets split into pieces of a_max_amount.
   * If no text between delimiters found then an empty row is returned, example:
   *   string_to_table( 'a,,b', ',' ) gives table ut_varchar2_list( 'a', null, 'b' );
   *
   * @param a_clob       the text to be split.
   * @param a_delimiter  the delimiter character or string (default chr(10) )
   * @param a_max_amount the maximum length of returned string (default 8191)
   * @return table of varchar2 values
   */
  function clob_to_table(a_clob clob, a_max_amount integer := 8191, a_delimiter varchar2:= chr(10)) return ut_varchar2_list;

  function table_to_clob(a_text_table ut_varchar2_list, a_delimiter varchar2:= chr(10)) return clob;

  function table_to_clob(a_integer_table ut_integer_list, a_delimiter varchar2:= chr(10)) return clob;

  /**
   * Returns time difference in seconds (with miliseconds) between given timestamps
   */
  function time_diff(a_start_time timestamp with time zone, a_end_time timestamp with time zone) return number;

  /**
   * Returns a text indented with spaces except the first line.
   */
  function indent_lines(a_text varchar2, a_indent_size integer := 4, a_include_first_line boolean := false) return varchar2;


  /**
   * Returns a list of object that are part of utPLSQL framework
   */
  function get_utplsql_objects_list return ut_object_names;

  /**
   * Append a item to the end of ut_varchar2_list
   */
  procedure append_to_list(a_list in out nocopy ut_varchar2_list, a_item varchar2);

  procedure append_to_clob(a_src_clob in out nocopy clob, a_clob_table t_clob_tab, a_delimiter varchar2 := chr(10));

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

  /**
   * Converts version string into version record
   *
   * @param    a_version_no string representation of version in format vX.X.X.X where X is a positive integer
   * @return   t_version    record with up to four positive numbers containing version
   * @throws   20214        if passed version string is not matching version pattern
   */
  function to_version(a_version_no varchar2) return t_version;


  /**
  * Saves data from dbms_output buffer into a global temporary table (cache)
  *   used to store dbms_output buffer captured before the run
  *
  */
  procedure save_dbms_output_to_cache;

  /**
  * Reads data from global temporary table (cache) abd puts it back into dbms_output
  *   used to recover dbms_output buffer data after a run is complete
  *
  */
  procedure read_cache_to_dbms_output;


  /**
   * Function is used to reference to utPLSQL owned objects in dynamic sql statements executed from packages with invoker rights
   *
   * @return the name of the utPSQL schema owner
   */
  function ut_owner return varchar2;


  /**
   * Used in dynamic sql select statements to maintain balance between
   *   number of hard-parses and optimiser accurancy for cardinality of collections
   *
   *
   * @return 3, for inputs of: 1-9; 33 for input of 10 - 99; 333 for (100 - 999)
   */
  function scale_cardinality(a_cardinality natural) return natural;

  function build_depreciation_warning(a_old_syntax varchar2, a_new_syntax varchar2) return varchar2;

  /**
  * Returns number as string. The value is represented as decimal according to XML standard:
  * https://www.w3.org/TR/xmlschema-2/#decimal
  */
  function to_xml_number_format(a_value number) return varchar2;

  /*It takes a collection of type ut_varchar2_list and it trims the characters passed as arguments for every element*/
  function trim_list_elements(a_list IN ut_varchar2_list, a_regexp_to_trim in varchar2 default '[:space:]') return ut_varchar2_list;

  /*It takes a collection of type ut_varchar2_list and it only returns the elements which meets the regular expression*/
  function filter_list(a_list IN ut_varchar2_list, a_regexp_filter in varchar2) return ut_varchar2_list;

end ut_utils;
/
