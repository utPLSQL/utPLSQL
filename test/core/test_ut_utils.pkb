create or replace package body test_ut_utils is

  gv_nls_value nls_session_parameters.value%type;

  procedure common_clob_to_table_exec(p_clob varchar2, p_delimiter varchar2, p_expected_list ut3.ut_varchar2_list, p_limit number) is
  begin
    execute immediate 'declare
  l_clob       clob := '''||p_clob||''';
  l_delimiter  varchar2(1) := '''||p_delimiter||''';
  l_expected   ut3.ut_varchar2_list := :p_expected_list;
  l_result     ut3.ut_varchar2_list;
  l_limit      integer := '||p_limit||q'[;
  l_result_str varchar2(32767);
  l_errors     integer := 0;
  function compare_element(a_element_id integer, a_expected ut3.ut_varchar2_list, a_actual ut3.ut_varchar2_list) return integer is
  begin
    if a_expected.exists(a_element_id) and a_actual.exists(a_element_id) then
      if a_expected(a_element_id) = a_actual(a_element_id) or a_expected(a_element_id) is null and  a_actual(a_element_id) is null then
        return 0;
      else
        dbms_output.put('a_expected('||a_element_id||')='||a_expected(a_element_id)||' | a_actual('||a_element_id||')='||a_actual(a_element_id));
      end if;
    end if;
    if not a_expected.exists(a_element_id) then
      dbms_output.put('a_expected('||a_element_id||') does not exist ');
    end if;
    if not a_actual.exists(a_element_id) then
      dbms_output.put('a_actual('||a_element_id||') does not exist ');
    end if;
    dbms_output.put_line(null);
    return 1;
  end;
begin
--Act
  select column_value bulk collect into l_result from table( ut3.ut_utils.clob_to_table(l_clob, l_limit, l_delimiter) );
  for i in 1 .. l_result.count loop
    l_result_str := l_result_str||''''||l_result(i)||''''||l_delimiter;
  end loop;
  l_result_str := rtrim(l_result_str,l_delimiter);
--Assert
  for i in 1 .. greatest(l_expected.count, l_result.count) loop
    l_errors := l_errors + compare_element(i, l_expected, l_result);
  end loop;
  ut.expect(l_errors).to_equal(0);
end;]' using p_expected_list;
  end;

  procedure test_clob_to_table is
  begin
    common_clob_to_table_exec('a,b,c,d', ',', ut3.ut_varchar2_list('a','b','c','d'), 1000);
    common_clob_to_table_exec( '', ',', ut3.ut_varchar2_list(), 1000);
    common_clob_to_table_exec( '1,b,c,d', '', ut3.ut_varchar2_list('1,b,','c,d'), 4);
    common_clob_to_table_exec( 'abcdefg,hijk,axa,a', ',', ut3.ut_varchar2_list('abc','def','g','hij','k','axa','a'), 3);
    common_clob_to_table_exec( ',a,,c,d,', ',', ut3.ut_varchar2_list('','a','','c','d',''), 1000);
  end;

  procedure test_to_char is
  begin
    ut.expect(ut3.ut_utils.test_result_to_char(-1),'test unknown').to_equal('Unknown(-1)');
    ut.expect(ut3.ut_utils.test_result_to_char(null),'test unknown').to_equal('Unknown(NULL)');
    ut.expect(ut3.ut_utils.test_result_to_char(ut3.ut_utils.gc_success),'test unknown').to_equal(ut3.ut_utils.gc_success_char);
  end;

  procedure test_to_string_blob is
    l_text     varchar2(32767) := 'A test char';
    l_value    blob := utl_raw.cast_to_raw(l_text);
    l_expected varchar2(32767) := ''''||rawtohex(l_value)||'''';
    l_result   varchar2(32767);
  begin
    l_result :=  ut3.ut_utils.to_String(l_value);
    ut.expect(l_result).to_equal(l_expected);
  end;

  procedure test_to_string_clob is
  l_value    clob := 'A test char';
  l_expected varchar2(32767) := ''''||l_value||'''';
  l_result   varchar2(32767);
  begin
    l_result :=  ut3.ut_utils.to_String(l_value);
    ut.expect(l_result).to_equal(l_expected);
  end;

  procedure test_to_string_date is
  l_value    date := to_date('2016-12-31 23:59:59', 'yyyy-mm-dd hh24:mi:ss');
  l_expected varchar2(100) := '2016-12-31T23:59:59';
  l_result   varchar2(32767);
  begin
    l_result :=  ut3.ut_utils.to_String(l_value);
    ut.expect(l_result).to_equal(l_expected);
  end;

  procedure to_string_null is
  begin
    ut.expect(ut3.ut_utils.to_String(to_blob(NULL))).to_equal('NULL');
    ut.expect(ut3.ut_utils.to_String(to_clob(NULL))).to_equal('NULL');
    ut.expect(ut3.ut_utils.to_String(to_date(NULL))).to_equal('NULL');
    ut.expect(ut3.ut_utils.to_String(to_number(NULL))).to_equal('NULL');
    ut.expect(ut3.ut_utils.to_String(to_timestamp(NULL))).to_equal('NULL');
  end;

  procedure to_string is
    l_value    timestamp(9) := to_timestamp('2016-12-31 23:59:59.123456789', 'yyyy-mm-dd hh24:mi:ss.ff');
    l_value2    timestamp(9) with local time zone:= to_timestamp('2016-12-31 23:59:59.123456789', 'yyyy-mm-dd hh24:mi:ss.ff');
    l_value3    timestamp(9) with time zone := to_timestamp_tz('2016-12-31 23:59:59.123456789 -8:00', 'yyyy-mm-dd hh24:mi:ss.ff tzh:tzm');
    l_value4    varchar2(20) := 'A test char';
    l_expected varchar2(100);
    l_result   varchar2(100);
    l_delimiter varchar2(10);
  begin
    select substr(value, 1, 1) into l_delimiter from nls_session_parameters t where t.parameter = 'NLS_NUMERIC_CHARACTERS';
    l_expected := '2016-12-31T23:59:59'||l_delimiter||'123456789';

    l_result :=  ut3.ut_utils.to_String(l_value);
    ut.expect(l_result,'Returns a full string representation of a timestamp with maximum precission').to_equal(l_expected);

    l_expected := '2016-12-31T23:59:59'||l_delimiter||'123456789';
    l_result :=  ut3.ut_utils.to_String(l_value2);
    ut.expect(l_result,'Returns a full string representation of a timestamp with maximum precission').to_equal(l_expected);

    l_expected := '2016-12-31T23:59:59'||l_delimiter||'123456789 -08:00';

    l_result :=  ut3.ut_utils.to_String(l_value3);
    ut.expect(l_result,'Returns a full string representation of a timestamp with maximum precission').to_equal(l_expected);

    l_expected := ''''||l_value4||'''';
    l_result :=  ut3.ut_utils.to_String(l_value4);
    ut.expect(l_result,'Returns a varchar2 eclosed in quotes').to_equal(l_expected);

  end;

  procedure to_string_big_blob is
    l_text     clob := lpad('A test char',32767,'1')||lpad('1',32767,'1');
    l_value    blob;
    l_result   varchar2(32767);
    function clob_to_blob(p_clob clob) return blob
    as
      l_blob          blob;
      l_dest_offset   integer := 1;
      l_source_offset integer := 1;
      l_lang_context  integer := dbms_lob.default_lang_ctx;
      l_warning       integer := dbms_lob.warn_inconvertible_char;
    begin
      dbms_lob.createtemporary(l_blob, true);
      dbms_lob.converttoblob(
        dest_lob    =>l_blob,
        src_clob    =>p_clob,
        amount      =>DBMS_LOB.LOBMAXSIZE,
        dest_offset =>l_dest_offset,
        src_offset  =>l_source_offset,
        blob_csid   =>DBMS_LOB.DEFAULT_CSID,
        lang_context=>l_lang_context,
        warning     =>l_warning
      );
      return l_blob;
    end;
  begin
    l_value := clob_to_blob(l_text);
  --Act
    l_result :=  ut3.ut_utils.to_String(l_value);
  --Assert
    ut.EXPECT(length(l_result)).to_equal(ut3.ut_utils.gc_max_output_string_length);
    ut.EXPECT(l_result).to_be_like('%'||ut3.ut_utils.gc_more_data_string);

  end;

  procedure to_string_big_clob is
    l_value    clob := lpad('A test char',32767,'1')||lpad('1',32767,'1');
    l_result   varchar2(32767);
  begin
  --Act
    l_result :=  ut3.ut_utils.to_String(l_value);
  --Assert
    ut.EXPECT(length(l_result)).to_equal(ut3.ut_utils.gc_max_output_string_length);
    ut.EXPECT(l_result).to_be_like('%'||ut3.ut_utils.gc_more_data_string);
  end;

  procedure to_string_big_number is
    l_value    number := 1234567890123456789012345678901234567890;
    l_expected varchar2(100) := '1234567890123456789012345678901234567890';
    l_result   varchar2(100);
  begin
  --Act
    l_result := ut3.ut_utils.to_String(l_value);
  --Assert
    ut.expect(l_result).TO_equal(l_expected);
  end;

  procedure to_string_big_varchar2 is
    l_value    varchar2(32767) := lpad('A test char',32767,'1');
    l_result   varchar2(32767);
  begin
  --Act
    l_result :=  ut3.ut_utils.to_String(l_value);
  --Assert
    ut.EXPECT(length(l_result)).to_equal(ut3.ut_utils.gc_max_output_string_length);
    ut.EXPECT(l_result).to_be_like('%'||ut3.ut_utils.gc_more_data_string);
  end;

  procedure to_string_big_tiny_number is
    l_value    number := 0.123456789012345678901234567890123456789;
    l_expected varchar2(100);
    l_result   varchar2(100);
    l_delimiter varchar2(1);
  begin
  --Act
    select substr(value, 1, 1) into l_delimiter from nls_session_parameters t where t.parameter = 'NLS_NUMERIC_CHARACTERS';
    l_expected := l_delimiter||'123456789012345678901234567890123456789';

    l_result :=  ut3.ut_utils.to_String(l_value);

  --Assert
    ut.expect(l_result).TO_equal(l_expected);

  end;

  procedure test_table_to_clob is
    procedure exec_table_to_clob(a_list ut3.ut_varchar2_list, a_delimiter varchar2, a_expected clob) is
      l_result clob;
    begin
      l_result := ut3.ut_utils.table_to_clob(a_list, a_delimiter);

      ut.expect(l_result).to_equal(a_expected, a_nulls_are_equal => true);
    end;
  begin
    exec_table_to_clob(null, ',', '');
    exec_table_to_clob(ut3.ut_varchar2_list(), ',', '');
    exec_table_to_clob(ut3.ut_varchar2_list('a', 'b', 'c', 'd'), ',', 'a,b,c,d');
    exec_table_to_clob(ut3.ut_varchar2_list('1,b,', 'c,d'), ',', '1,b,,c,d');
    exec_table_to_clob(ut3.ut_varchar2_list('', 'a', '', 'c', 'd', ''), ',', ',a,,c,d,');
  end;

  procedure test_append_with_multibyte is
    l_lines   sys.dbms_preprocessor.source_lines_t;
    l_result  clob;
  begin
    l_lines := sys.dbms_preprocessor.get_post_processed_source(
      object_type => 'PACKAGE',
      schema_name => user,
      object_name => 'TST_CHARS'
    );

    for i in 1..l_lines.count loop
      l_result := null;
      ut3.ut_utils.append_to_clob(l_result, l_lines(i));

      --Assert
      ut.expect(dbms_lob.getlength(l_result),'Error for index '||i).to_equal(dbms_lob.getlength(l_lines(i)));
    end loop;
  end;

  procedure setup_append_with_multibyte is
    pragma autonomous_transaction;
  begin
    select value into gv_nls_value from nls_session_parameters where parameter = 'NLS_DATE_LANGUAGE';
    execute immediate 'alter session set nls_date_language=ENGLISH';
    execute immediate 'create or replace package tst_chars as
--                 2) Status of the process = 😡PE😡 with no linked data
end;';
    execute immediate 'alter session set nls_date_language=RUSSIAN';

  end;
  procedure clean_append_with_multibyte is
    pragma autonomous_transaction;
  begin
    execute immediate 'alter session set nls_date_language='||gv_nls_value;
    execute immediate 'drop package tst_chars';
  end;

  procedure test_clob_to_table_multibyte is
    l_varchar2_byte_limit integer := 32767;
    l_workaround_byte_limit integer := 8191;
    l_singlebyte_string_max_size varchar2(32767 char) := rpad('x',l_varchar2_byte_limit,'x');
    l_twobyte_character char(1 char) := '�?';
    l_clob_multibyte clob := l_twobyte_character||l_singlebyte_string_max_size; --here we have 32769(2+32767) bytes and 32768 chars
    l_expected ut3.ut_varchar2_list := ut3.ut_varchar2_list();
    l_result   ut3.ut_varchar2_list;
  begin
    l_expected.extend(1);
    l_expected(1) := l_twobyte_character||substr(l_singlebyte_string_max_size,1,l_workaround_byte_limit-1);
  --Act
    l_result := ut3.ut_utils.clob_to_table(l_clob_multibyte);
  --Assert
    ut.expect(l_result(1)).to_equal(l_expected(1));
  end;

  procedure test_to_version_split is
    l_version ut3.ut_utils.t_version;
  begin
    l_version := ut3.ut_utils.to_version('v034.0.0456.0333');
    ut.expect(l_version.major).to_equal(34);
    ut.expect(l_version.minor).to_equal(0);
    ut.expect(l_version.bugfix).to_equal(456);
    ut.expect(l_version.build).to_equal(333);
  end;

  procedure test_trim_list_elements
  is
    l_list_to_be_equal ut3.ut_varchar2_list := ut3.ut_varchar2_list('hello', 'world', 'okay');
    l_list ut3.ut_varchar2_list := ut3.ut_varchar2_list(' hello  ', chr(9)||'world ', 'okay');
  begin
    --Act
    l_list := ut3.ut_utils.trim_list_elements(l_list);
    --Assert
    ut.expect(anydata.convertcollection(l_list)).to_equal(anydata.convertcollection(l_list_to_be_equal));
  end;
  
  procedure trim_list_elemts_null_collect
  is
    l_list_to_be_null ut3.ut_varchar2_list;
  begin
    --Act
    l_list_to_be_null := ut3.ut_utils.trim_list_elements(l_list_to_be_null);
    --Assert
    ut.expect(anydata.convertcollection(l_list_to_be_null)).to_be_null;
  end;
  
  procedure trim_list_elemts_empty_collect
  is
    l_list_to_be_empty ut3.ut_varchar2_list := ut3.ut_varchar2_list();
  begin
    --Act
    l_list_to_be_empty := ut3.ut_utils.trim_list_elements(l_list_to_be_empty);
    --Assert
    ut.expect(anydata.convertcollection(l_list_to_be_empty)).to_be_empty;
  end;
  
  procedure test_filter_list
  is
    l_list_to_be_equal ut3.ut_varchar2_list := ut3.ut_varchar2_list('-12458', '8956', '789');
    l_list ut3.ut_varchar2_list := ut3.ut_varchar2_list('-12458', '8956', 'okay', null,'458963', '789');
  begin
    --Act
    l_list := ut3.ut_utils.filter_list(l_list, '^-?[[:digit:]]{1,5}$');
    --Assert
    ut.expect(anydata.convertcollection(l_list)).to_equal(anydata.convertcollection(l_list_to_be_equal));
  end;
  
  procedure filter_list_null_collection
  is
    l_list_to_be_null ut3.ut_varchar2_list;
  begin
    --Act
    l_list_to_be_null := ut3.ut_utils.filter_list(l_list_to_be_null, '^-?[[:digit:]]{1,5}$');
    --Assert
    ut.expect(anydata.convertcollection(l_list_to_be_null)).to_be_null;
  end;
  
  procedure filter_list_empty_collection
  is
    l_list_to_be_empty ut3.ut_varchar2_list := ut3.ut_varchar2_list();
  begin
    --Act
    l_list_to_be_empty := ut3.ut_utils.filter_list(l_list_to_be_empty, '^-?[[:digit:]]{1,5}$');
    --Assert
    ut.expect(anydata.convertcollection(l_list_to_be_empty)).to_be_empty;
  end;

  procedure replace_multiline_comments
  is
    l_source   clob;
    l_actual   clob;
    l_expected clob;
  begin
    --Arrange
    l_source := q'[
create or replace package dummy as

  -- single line comment with disabled /* multi-line comment */
  gv_text0 varchar2(200) := q'{/* multi-line comment
    in escaped q'multi-line
    string*/}';
  gv_text1 varchar2(200) := '/* multi-line comment in a string*/';
  gv_text2 varchar2(200) := '/* multi-line comment
    in a multi-line
    string*/';
  -- ignored start of multi-line comment /*
  -- ignored end of multi-line comment */
  /* proper
   multi-line comment */
  gv_text3 varchar2(200) := 'some text'; /* multiline comment*/  --followed by single-line comment
  /* multi-line comment in one line*/
  gv_text4 varchar2(200) := q'{/* multi-line comment
    in escaped q'multi-line
    string*/}';
end;
]';
  l_expected := q'[
create or replace package dummy as

  -- single line comment with disabled /* multi-line comment */
  gv_text0 varchar2(200) := q'{/* multi-line comment
    in escaped q'multi-line
    string*/}';
  gv_text1 varchar2(200) := '/* multi-line comment in a string*/';
  gv_text2 varchar2(200) := '/* multi-line comment
    in a multi-line
    string*/';
  -- ignored start of multi-line comment /*
  -- ignored end of multi-line comment */
  ]'||q'[

  gv_text3 varchar2(200) := 'some text';   --followed by single-line comment
  ]'||q'[
  gv_text4 varchar2(200) := q'{/* multi-line comment
    in escaped q'multi-line
    string*/}';
end;
]';
    --Act
    l_actual := ut3.ut_utils.replace_multiline_comments(l_source);
    --Assert
    ut.expect(l_actual).to_equal(l_expected);
  end;
end test_ut_utils;
/
