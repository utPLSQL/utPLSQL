create or replace package ut_utils authid definer is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project

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

  gc_version                 constant varchar2(50) := 'v3.1.13.4055-develop';
    
  subtype t_executable_type      is varchar2(30);
  gc_before_all                  constant t_executable_type := 'beforeall';
  gc_before_each                 constant t_executable_type := 'beforeeach';
  gc_before_test                 constant t_executable_type := 'beforetest';
  gc_test_execute                constant t_executable_type := 'test';
  gc_after_test                  constant t_executable_type := 'aftertest';
  gc_after_each                  constant t_executable_type := 'aftereach';
  gc_after_all                   constant t_executable_type := 'afterall';

  /* Constants: Test Results */
  subtype t_test_result   is binary_integer range 0 .. 3;
  gc_disabled                constant t_test_result := 0; -- test/suite was disabled
  gc_success                 constant t_test_result := 1; -- test passed
  gc_failure                 constant t_test_result := 2; -- one or more expectations failed
  gc_error                   constant t_test_result := 3; -- exception was raised

  gc_disabled_char           constant varchar2(8) := 'Disabled'; -- test/suite was disabled
  gc_success_char            constant varchar2(7) := 'Success'; -- test passed
  gc_failure_char            constant varchar2(7) := 'Failure'; -- one or more expectations failed
  gc_error_char              constant varchar2(5) := 'Error'; -- exception was raised

  gc_cdata_start_tag         constant varchar2(10) := '<![CDATA[';
  gc_cdata_end_tag           constant varchar2(10) := ']]>';
  gc_cdata_end_tag_wrap      constant varchar2(30) := ']]'||gc_cdata_end_tag||gc_cdata_start_tag||'>';


  /*
    Constants: Rollback type for ut_test_object
  */
  subtype t_rollback_type is binary_integer range 0 .. 1;
  gc_rollback_auto           constant t_rollback_type := 0; -- rollback after each test and suite
  gc_rollback_manual         constant t_rollback_type := 1; -- leave transaction control manual
  gc_rollback_default        constant t_rollback_type := gc_rollback_auto;

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

  -- Version number provided is not in valid format
  ex_invalid_version_no exception;
  gc_invalid_version_no constant pls_integer := -20214;
  pragma exception_init(ex_invalid_version_no, -20214);

  -- Version number provided is not in valid format
  ex_out_buffer_timeout exception;
  gc_out_buffer_timeout constant pls_integer := -20215;
  pragma exception_init(ex_out_buffer_timeout, -20215);

  ex_invalid_package exception;
  gc_invalid_package constant pls_integer := -6550;
  pragma exception_init(ex_invalid_package, -6550);

  ex_failure_for_all exception;
  gc_failure_for_all constant pls_integer := -24381;
  pragma exception_init (ex_failure_for_all, -24381);

  ex_dml_for_all exception;
  gc_dml_for_all constant pls_integer := -20216;
  pragma exception_init (ex_dml_for_all, -20216);

  ex_value_too_large exception;
  gc_value_too_large constant pls_integer := -20217;
  pragma exception_init (ex_value_too_large, -20217);

  ex_xml_processing exception;
  gc_xml_processing constant pls_integer := -19202;
  pragma exception_init (ex_xml_processing, -19202);
  
  ex_failed_open_cur exception;
  gc_failed_open_cur constant pls_integer := -20218;
  pragma exception_init (ex_failed_open_cur, -20218);  
  
  gc_max_storage_varchar2_len constant integer := 4000;
  gc_max_output_string_length constant integer := 4000;
  gc_more_data_string         constant varchar2(5) := '[...]';
  gc_more_data_string_len     constant integer := length( gc_more_data_string );
  gc_number_format            constant varchar2(100) := 'TM9';
  gc_date_format              constant varchar2(100) := 'syyyy-mm-dd"T"hh24:mi:ss';
  gc_timestamp_format         constant varchar2(100) := 'syyyy-mm-dd"T"hh24:mi:ssxff';
  gc_timestamp_tz_format      constant varchar2(100) := 'syyyy-mm-dd"T"hh24:mi:ssxff tzh:tzm';
  gc_null_string              constant varchar2(4) := 'NULL';
  gc_empty_string             constant varchar2(5) := 'EMPTY';

  gc_bc_fetch_limit           constant integer := 1000;
  gc_diff_max_rows            constant integer := 20;

  gc_max_objects_fetch_limit  constant integer := 1000000;

  /** 
  * Regexp to validate tag
  */
  gc_word_no_space              constant varchar2(50) := '^(\w|\S)+$';

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

  function to_string(
    a_value varchar2,
    a_quote_char varchar2 := '''',
    a_max_output_len in number := gc_max_output_string_length
  ) return varchar2;

  function to_string(
    a_value clob,
    a_quote_char varchar2 := '''',
    a_max_output_len in number := gc_max_output_string_length
  ) return varchar2;

  function to_string(
    a_value blob,
    a_quote_char varchar2 := '''',
    a_max_output_len in number := gc_max_output_string_length
  ) return varchar2;

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
   *
   * Splits a given string into table of string by delimiter.
   * The delimiter gets removed.
   * If null a_string passed, empty table is returned.
   * If null a_delimiter passed, a_string is returned as element of result table.
   * If null a_skip_leading_delimiter, it defaults to 'N'
   * If no occurrence of a_delimiter found in a_text then text is returned as a single row of the table.
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
   *
   * Splits each string in table of string into a table of string using specified delimiter.
   * The delimiter gets removed.
   * If null a_delimiter passed, a_list is returned as-is.
   * If null a_list passed, empty table is returned.
   * If null a_skip_leading_delimiter, it defaults to 'N'
   * If no occurrence of a_delimiter found in a_text then text is returned as a single row of the table.
   * If no text between delimiters found then an empty row is returned, example:
   *   string_table_to_table( a_list => ut_varchar2_list('x','y',null,'a,,b'), a_delimiter=>',' ) gives table ut_varchar2_list( 'x', 'y', null, 'a', null, 'b' );
   *
   * @param a_list                   the table of texts to be split.
   * @param a_delimiter              the delimiter character or string
   * @param a_skip_leading_delimiter determines if the leading delimiter should be ignored, used by clob_to_table
   *
   * @return table of varchar2 values
   */
  function string_table_to_table(a_list ut_varchar2_list, a_delimiter varchar2:= chr(10), a_skip_leading_delimiter varchar2 := 'N') return ut_varchar2_list;

  /**
   * Splits a given string into table of string by delimiter.
   * Default value of a_max_amount is 8191 because of code can contains multibyte character.
   * The delimiter gets removed.
   * If null a_clob passed, empty table is returned.
   * If null a_delimiter passed, a_string is returned as element of result table.
   * If null a_skip_leading_delimiter, it defaults to 'N'
   * If no occurrence of a_delimiter found in a_text then text is returned as a single row of the table.
   * If split text is longer than a_max_amount it gets split into pieces of a_max_amount.
   * If no text between delimiters found then an empty row is returned, example:
   *   clob_to_table( 'a,,b', ',' ) gives table ut_varchar2_list( 'a', null, 'b' );
   *
   * @param a_clob       the text to be split.
   * @param a_delimiter  the delimiter character or string (default chr(10) )
   * @param a_max_amount the maximum length of returned string (default 8191)
   * @return table of varchar2 values
   */
  function clob_to_table(a_clob clob, a_max_amount integer := 8191, a_delimiter varchar2:= chr(10)) return ut_varchar2_list;

  function table_to_clob(a_text_table ut_varchar2_list, a_delimiter varchar2:= chr(10)) return clob;
  
  function table_to_clob(a_text_table ut_varchar2_rows, a_delimiter varchar2:= chr(10)) return clob;
  
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

  /**
   * Append a item to the end of ut_varchar2_rows
   */
  procedure append_to_list(a_list in out nocopy ut_varchar2_rows, a_item varchar2);

  /**
   * Append a item to the end of ut_varchar2_rows
   */
  procedure append_to_list(a_list in out nocopy ut_varchar2_rows, a_item clob);

  /**
   * Append a list of items to the end of ut_varchar2_rows
   */
  procedure append_to_list(a_list in out nocopy ut_varchar2_rows, a_items ut_varchar2_rows);

  /**
   * Append a list of items to the end of ut_varchar2_list
   */
  procedure append_to_list(a_list in out nocopy ut_varchar2_list, a_items ut_varchar2_list);

  procedure append_to_clob(a_src_clob in out nocopy clob, a_clob_table t_clob_tab, a_delimiter varchar2 := chr(10));

  procedure append_to_clob(a_src_clob in out nocopy clob, a_new_data clob);

  procedure append_to_clob(a_src_clob in out nocopy clob, a_new_data varchar2);

  function convert_collection(a_collection ut_varchar2_list) return ut_varchar2_rows;

  function to_xpath(a_list varchar2, a_ancestors varchar2 := '/*/') return varchar2;

  function to_xpath(a_list ut_varchar2_list, a_ancestors varchar2 := '/*/') return varchar2;

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


  /**
  * Returns xml header. If a_encoding is not null, header will include encoding attribute with provided value
  */
  function get_xml_header(a_encoding varchar2) return varchar2;


  /**
  * Takes a collection of type ut_varchar2_list and it trims the characters passed as arguments for every element
  */
  function trim_list_elements(a_list IN ut_varchar2_list, a_regexp_to_trim in varchar2 default '[:space:]') return ut_varchar2_list;

  /**
  * Takes a collection of type ut_varchar2_list and it only returns the elements which meets the regular expression
  */
  function filter_list(a_list IN ut_varchar2_list, a_regexp_filter in varchar2) return ut_varchar2_list;

  -- Generates XMLGEN escaped string
  function xmlgen_escaped_string(a_string in varchar2) return varchar2;

  /**
  * Replaces multi-line comments in given source-code with empty lines
  */
  function replace_multiline_comments(a_source clob) return clob;

   /**
   * Returns list of sub-type reporters for given list of super-type reporters
   */
  function get_child_reporters(a_for_reporters ut_reporters_info := null) return ut_reporters_info;
  
  /**
  * Remove given ORA error from stack
  */
  function remove_error_from_stack(a_error_stack varchar2, a_ora_code number) return varchar2;
  
  /**
  * Check if xml name is valid if not build a valid name
  */
  function get_valid_xml_name(a_name varchar2) return varchar2;

  /**
  * Converts input list into a list surrounded by CDATA tags
  * All CDATA end tags get escaped using recommended method from https://en.wikipedia.org/wiki/CDATA#Nesting
  */
  function to_cdata(a_lines ut_varchar2_rows) return ut_varchar2_rows;

  /**
  * Converts input CLOB into a CLOB surrounded by CDATA tags
  * All CDATA end tags get escaped using recommended method from https://en.wikipedia.org/wiki/CDATA#Nesting
  */
  function to_cdata(a_clob clob) return clob;

  /**
  * Add prefix word to elements of list
  */
  function add_prefix(a_list ut_varchar2_list, a_prefix varchar2, a_connector varchar2 := '/') return ut_varchar2_list;

  function add_prefix(a_item varchar2, a_prefix varchar2, a_connector varchar2 := '/') return varchar2;

  function strip_prefix(a_item varchar2, a_prefix varchar2, a_connector varchar2 := '/') return varchar2;


  subtype t_hash  is raw(128);

  /*
  * Wrapper function for calling dbms_crypto.hash
  */
  function get_hash(a_data raw, a_hash_type binary_integer := dbms_crypto.hash_sh1)  return t_hash;

  /*
  * Wrapper function for calling dbms_crypto.hash
  */
  function get_hash(a_data clob, a_hash_type binary_integer := dbms_crypto.hash_sh1) return t_hash;

  /*
  * Returns a hash value of suitepath based on input path and random seed
  */
  function hash_suite_path(a_path varchar2, a_random_seed positiven) return varchar2;

  /*
  * Verifies that the input string is a qualified SQL name using sys.dbms_assert.qualified_sql_name
  * If null value passed returns null
  */
  function qualified_sql_name(a_name varchar2) return varchar2;
 
  /*
  * Return value of interval in plain english
  */  
  function interval_to_text(a_interval dsinterval_unconstrained) return varchar2;
  
  /*
  * Return value of interval in plain english
  */    
  function interval_to_text(a_interval yminterval_unconstrained) return varchar2;
  
end ut_utils;
/
