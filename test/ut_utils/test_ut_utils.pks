create or replace package test_ut_utils as

  --%suite(Testing common utility package: ut_utils)
  --%suitepath(utplsql.core)

  --%context(clob_to_table)

  --%test(splits clob by delimiter)
  procedure clob_to_table_by_delim;

  --%test(returns empty table for null clob)
  procedure clob_to_table_null_data;

  --%test(splits table by char limit when no delimiter)
  procedure clob_to_table_char_limit;

  --%test(splits table by char limit on overflow and continues by delimiter)
  procedure clob_to_table_char_limit_delim;

  --%test(returns empty lines for null data between delimiter)
  procedure clob_to_table_empty_lines;

  --%endcontext

  --%test(test_result_to_char)
  procedure test_result_to_char;

  --%test(to_test_result converts boolean value to test result integer)
  procedure to_test_result;

  --%test(to_string on null blob)
  procedure to_string_null_blob;
  --%test(to_string on blob)
  procedure to_string_blob;

--   --%test(to_string on null clob)
--   procedure to_string_null_clob;
--   --%test(to_string on clob)
--   procedure to_string_clob;
--   --%test(to_string on clob no surrounding quotes)
--   procedure to_string_clob_no_quotes;
--   --%test(to_string on clob other surrounding quotes)
--   procedure to_string_clob_other_quotes;
--
--   --%test(to_string on null number)
--   procedure to_string_null_number;
--   --%test(to_string on number)
--   procedure to_string_number;
--
--   --%test(to_string on null timestamp)
--   procedure to_string_null_timestamp;
--   --%test(to_string on timestamp)
--   procedure to_string_timestamp;
--
--   --%test(to_string on null timestamp with time zone)
--   procedure to_string_null_timestamp_tz;
--   --%test(to_string on timestamp with time zone)
--   procedure to_string_timestamp_tz;
--
--   --%test(to_string on null timestamp with local time zone)
--   procedure to_string_null_timestamp_ltz;
--   --%test(to_string on timestamp with local time zone)
--   procedure to_string_timestamp_ltz;
--
--   --%test(to_string on null varchar)
--   procedure to_string_null_varchar;
--   --%test(to_string on varchar)
--   procedure to_string_varchar;
--   --%test(to_string on varchar no surrounding quotes)
--   procedure to_string_varchar_no_quotes;
--   --%test(to_string on varchar non default surrounding quotes)
--   procedure to_string_varchar_other_quotes;

end;
/
