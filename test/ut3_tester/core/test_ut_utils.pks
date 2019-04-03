create or replace package test_ut_utils is

  --%suite(ut_utils)
  --%suitepath(utplsql.ut3_tester.core)

  function get_numeric_delimiter return varchar2;

  --%test(clob_to_table - Converts a clob into ut_varchar2_list using specified delimiter)
  procedure test_clob_to_table;

  --%test(test_result_to_char - Converts numeric test result to character representation)
  procedure test_test_result_to_char;


  --%context(to_string)

  --%test(Returns 'EMPTY' string for NULL BLOB)
  procedure to_string_emptyblob;

  --%test(Returns 'EMPTY' string for NULL CLOB)
  procedure to_string_emptyclob;

  --%test(Returns 'NULL' string for NULL BLOB)
  procedure to_string_nullblob;

  --%test(Returns 'NULL' string for NULL CLOB)
  procedure to_string_nullclob;

  --%test(Returns 'NULL' string for NULL date)
  procedure to_string_nulldate;

  --%test(Returns 'NULL' string for NULL number)
  procedure to_string_nullnumber;

  --%test(Returns 'NULL' string for NULL timestamp)
  procedure to_string_nulltimestamp;

  --%test(Returns 'NULL' string for NULL timestamp with local timezone)
  procedure to_string_nulltimestamp_ltz;

  --%test(Returns 'NULL' string for NULL timestamp with timezone)
  procedure to_string_nulltimestamp_tz;

  --%test(Returns 'NULL' string for NULL varchar)
  procedure to_string_nullvarchar2;

  --%test(Returns string representation of BLOB)
  procedure to_string_blob;

  --%test(Returns string representation of CLOB)
  procedure to_string_clob;

  --%test(Returns string representation of date)
  procedure to_string_date;

  --%test(Returns string representation of timestamp)
  procedure to_string_timestamp;

  --%test(Returns string representation of timestamp with local timezone)
  procedure to_string_timestamp_ltz;

  --%test(Returns string representation of timestamp with timezone)
  procedure to_string_timestamp_tz;

  --%test(Returns varchar value)
  procedure to_string_varchar2;

  --%test(Returns BLOB trimmed to 4000 chars with trailing [...])
  procedure to_string_verybigblob;

--%test(Returns CLOB trimmed to 4000 chars with trailing [...])
  procedure to_string_verybigclob;

  --%test(Returns string representation of large number)
  procedure to_string_verybignumber;

  --%test(Returns varchar2 trimmed to 4000 chars with trailing [...])
  procedure to_string_verybigvarchar2;

  --%test(Returns string representation of small number)
  procedure to_string_verysmallnumber;

  --%endcontext

  --%test(table_to_clob - converts ut_varchar2_list into a CLOB value)
  procedure test_table_to_clob;

  --%test(append_to_clob - adds multibyte varchar to CLOB)
  --%beforetest(setup_append_with_multibyte)
  --%aftertest(clean_append_with_multibyte)
  procedure test_append_with_multibyte;
  procedure setup_append_with_multibyte;
  procedure clean_append_with_multibyte;

  --%test(clob_to_table - converts multibyte CLOB to ut_varchar2_list)
  --%disabled(We cannot run this test successfully on 12.1 until we change NLSCHARACTERSET from US7ASCII to AL32UTF8)
  procedure test_clob_to_table_multibyte;

  --%test(to_version - splits version string into individual version components)
  procedure test_to_version_split;

  --%context(trim_list_elements)

  --%test(Trims the elements of a collection)
  procedure test_trim_list_elements;
  
  --%test(Trim list elements with null collection)
  procedure trim_list_elemts_null_collect;
  
  --%test(Trim list elements with empty collection)
  procedure trim_list_elemts_empty_collect;

  --%endcontext

  --%context(filter_list)

  --%test(Filters the collection's elements)
  procedure test_filter_list;

  --%test(Filter list elements with null collection)
  procedure filter_list_null_collection;
  
  --%test(Filter list elements with empty collection)
  procedure filter_list_empty_collection;

  --%endcontext

  --%test(replace_multiline_comments - replaces multi-line comments with empty lines)
  procedure replace_multiline_comments;

end test_ut_utils;
/
