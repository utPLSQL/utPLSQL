create or replace package body test_ut_utils as

  procedure clob_to_table_test(
    a_clob clob, a_expected ut3.ut_varchar2_list,
    a_delimiter  varchar2 := ',',
    a_overflow_limit integer := 1000
  ) is
    l_result     ut3.ut_varchar2_list;
  begin
    --Act
    l_result := ut3.ut_utils.clob_to_table(a_clob, a_overflow_limit, a_delimiter);
    --Assert
    ut.expect(anydata.convertCollection(l_result)).to_( equal(anydata.convertCollection(a_expected)) );
  end;

  procedure clob_to_table_by_delim is
  begin
    clob_to_table_test( a_clob => 'a,b,c,d', a_expected => ut3.ut_varchar2_list('a','b','c','d') );
  end;

  --%test(clob_to_table returns empty table for null clob)
  procedure clob_to_table_null_data is
  begin
    clob_to_table_test( a_clob => null, a_expected => ut3.ut_varchar2_list() );
  end;

  --%test(clob_to_table splits table by char limit when no delimiter)
  procedure clob_to_table_char_limit is
  begin
    clob_to_table_test(
      a_clob => '1,2,3,4',
      a_expected => ut3.ut_varchar2_list('1,2,','3,4'),
      a_delimiter => '',
      a_overflow_limit => 4
    );
  end;

  --%test(clob_to_table splits table by char limit on overflow and continues by delimiter)
  procedure clob_to_table_char_limit_delim is
  begin
    clob_to_table_test(
      a_clob => 'abcdefg,hijk,axa,a',
      a_expected => ut3.ut_varchar2_list('abc','def','g','hij','k','axa','a'),
      a_overflow_limit => 3
    );
  end;

  --%test(clob_to_table returns empty lines for null data between delimiter)
  procedure clob_to_table_empty_lines is
  begin
    clob_to_table_test(
      a_clob => ',a,,c,d,',
      a_expected => ut3.ut_varchar2_list('','a','','c','d','')
    );
  end;

  --%test(test_result_to_char)
  procedure test_result_to_char is
  begin
    ut.expect( ut3.ut_utils.test_result_to_char(NULL)).to_equal('Unknown(NULL)');
    ut.expect( ut3.ut_utils.test_result_to_char(-1)).to_equal('Unknown(-1)');
    ut.expect( ut3.ut_utils.test_result_to_char(ut3.ut_utils.tr_disabled)).to_equal(ut3.ut_utils.tr_disabled_char);
    ut.expect( ut3.ut_utils.test_result_to_char(ut3.ut_utils.tr_success)).to_equal(ut3.ut_utils.tr_success_char);
    ut.expect( ut3.ut_utils.test_result_to_char(ut3.ut_utils.tr_failure)).to_equal(ut3.ut_utils.tr_failure_char);
    ut.expect( ut3.ut_utils.test_result_to_char(ut3.ut_utils.tr_error)).to_equal(ut3.ut_utils.tr_error_char);
  end;

  --%test(to_test_result converts boolean value to test result integer)
  procedure to_test_result is
  begin
    ut.expect( ut3.ut_utils.to_test_result(true)).to_equal(ut3.ut_utils.tr_success);
    ut.expect( ut3.ut_utils.to_test_result(false)).to_equal(ut3.ut_utils.tr_failure);
    ut.expect( ut3.ut_utils.to_test_result(null)).to_equal(ut3.ut_utils.tr_failure);
  end;

  --%test(to_string on null blob)
  procedure to_string_null_blob is
  begin
    ut.expect( ut3.ut_utils.to_string(to_blob(null)) ).to_equal('NULL');
  end;

  --%test(to_string on blob)
  procedure to_string_blob is
    l_text     varchar2(32767) := 'A test char';
    l_value    blob := utl_raw.cast_to_raw(l_text);
    l_expected varchar2(32767) := ''''||rawtohex(l_value)||'''';
  begin
    ut.expect( ut3.ut_utils.to_string(l_value) ).to_equal(l_expected);
  end;

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