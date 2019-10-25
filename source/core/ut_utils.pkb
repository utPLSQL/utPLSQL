create or replace package body ut_utils is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

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
  * Constants regex used to validate XML name
  */
  gc_invalid_first_xml_char  constant varchar2(50)  := '[^_a-zA-Z]';
  gc_invalid_xml_char        constant varchar2(50)  := '[^_a-zA-Z0-9\.-]';
  gc_full_valid_xml_name     constant varchar2(50)  := '^([_a-zA-Z])([_a-zA-Z0-9\.-])*$';

  function surround_with(a_value varchar2, a_quote_char varchar2) return varchar2 is
  begin
    return case when a_quote_char is not null then a_quote_char||a_value||a_quote_char else a_value end;
  end;

  function test_result_to_char(a_test_result integer) return varchar2 as
    l_result varchar2(20);
  begin
    if a_test_result = gc_success then
      l_result := gc_success_char;
    elsif a_test_result = gc_failure then
      l_result := gc_failure_char;
    elsif a_test_result = gc_error then
      l_result := gc_error_char;
    elsif a_test_result = gc_disabled then
      l_result := gc_disabled_char;
    else
      l_result := 'Unknown(' || coalesce(to_char(a_test_result),'NULL') || ')';
    end if ;
    return l_result;
  end test_result_to_char;


  function to_test_result(a_test boolean) return integer is
    l_result integer;
  begin
    if a_test then
      l_result := gc_success;
    else
      l_result := gc_failure;
    end if;
    return l_result;
  end;

  function gen_savepoint_name return varchar2 is
  begin
    return 's'||trim(to_char(ut_savepoint_seq.nextval,'0000000000000000000000000000'));
  end;

  procedure debug_log(a_message varchar2) is
  begin
    $if $$ut_trace $then
      dbms_output.put_line(a_message);
    $else
      null;
    $end
  end;

  procedure debug_log(a_message clob) is
    l_varchars ut_varchar2_list;
  begin
    $if $$ut_trace $then
      l_varchars := clob_to_table(a_message);
      for i in 1..l_varchars.count loop
        dbms_output.put_line(l_varchars(i));
      end loop;
    $else
      null;
    $end
  end;

  function to_string(
    a_value varchar2,
    a_quote_char varchar2 := '''',
    a_max_output_len in number := gc_max_output_string_length
  ) return varchar2 is
    l_result                  varchar2(32767);
    c_length                  constant integer := coalesce( length( a_value ), 0 );
    c_max_input_string_length constant integer := a_max_output_len - coalesce( length( a_quote_char ) * 2, 0 );
    c_overflow_substr_len     constant integer := c_max_input_string_length - gc_more_data_string_len;
  begin
    if c_length = 0 then
      l_result := gc_null_string;
    elsif c_length <= c_max_input_string_length then
      l_result := surround_with(a_value, a_quote_char);
    else
      l_result := surround_with(substr(a_value, 1, c_overflow_substr_len ), a_quote_char) || gc_more_data_string;
    end if ;
    return l_result;
  end;

  function to_string(
    a_value clob,
    a_quote_char varchar2 := '''',
    a_max_output_len in number := gc_max_output_string_length
  ) return varchar2 is
    l_result                  varchar2(32767);
    c_length                  constant integer := coalesce(dbms_lob.getlength(a_value), 0);
    c_max_input_string_length constant integer := a_max_output_len - coalesce( length( a_quote_char ) * 2, 0 );
    c_overflow_substr_len     constant integer := c_max_input_string_length - gc_more_data_string_len;
  begin
    if a_value is null then
      l_result := gc_null_string;
    elsif c_length = 0 then
      l_result := gc_empty_string;
    elsif c_length <= c_max_input_string_length then
      l_result := surround_with(a_value,a_quote_char);
    else
      l_result := surround_with(dbms_lob.substr(a_value, c_overflow_substr_len), a_quote_char) || gc_more_data_string;
    end if;
    return l_result;
  end;

  function to_string(
    a_value blob,
    a_quote_char varchar2 := '''',
    a_max_output_len in number := gc_max_output_string_length
  ) return varchar2 is
    l_result                  varchar2(32767);
    c_length                  constant integer := coalesce(dbms_lob.getlength(a_value), 0);
    c_max_input_string_length constant integer := a_max_output_len - coalesce( length( a_quote_char ) * 2, 0 );
    c_overflow_substr_len     constant integer := c_max_input_string_length - gc_more_data_string_len;
  begin
    if a_value is null then
      l_result := gc_null_string;
    elsif c_length = 0 then
      l_result := gc_empty_string;
    elsif c_length <= c_max_input_string_length then
      l_result := surround_with(rawtohex(a_value),a_quote_char);
    else
      l_result := to_string( rawtohex(dbms_lob.substr(a_value, c_overflow_substr_len)) );
    end if ;
    return l_result;
  end;

  function to_string(a_value boolean) return varchar2 is
  begin
    return case a_value when true then 'TRUE' when false then 'FALSE' else gc_null_string end;
  end;

  function to_string(a_value number) return varchar2 is
  begin
    return coalesce(to_char(a_value,gc_number_format), gc_null_string);
  end;

  function to_string(a_value date) return varchar2 is
  begin
    return coalesce(to_char(a_value,gc_date_format), gc_null_string);
  end;

  function to_string(a_value timestamp_unconstrained) return varchar2 is
  begin
    return coalesce(to_char(a_value,gc_timestamp_format), gc_null_string);
  end;

  function to_string(a_value timestamp_tz_unconstrained) return varchar2 is
  begin
    return coalesce(to_char(a_value,gc_timestamp_tz_format), gc_null_string);
  end;

  function to_string(a_value timestamp_ltz_unconstrained) return varchar2 is
  begin
    return coalesce(to_char(a_value,gc_timestamp_format), gc_null_string);
  end;

  function to_string(a_value yminterval_unconstrained) return varchar2 IS
  begin
    return coalesce(to_char(a_value), gc_null_string);
  end;

  function to_string(a_value dsinterval_unconstrained) return varchar2 IS
  begin
    return coalesce(to_char(a_value), gc_null_string);
  end;


  function boolean_to_int(a_value boolean) return integer is
  begin
    return case a_value when true then 1 when false then 0 end;
  end;

  function int_to_boolean(a_value integer) return boolean is
  begin
    return case a_value when 1 then true when 0 then false end;
  end;

  function string_to_table(a_string varchar2, a_delimiter varchar2:= chr(10), a_skip_leading_delimiter varchar2 := 'N') return ut_varchar2_list is
    l_offset                 integer := 1;
    l_delimiter_position     integer;
    l_skip_leading_delimiter boolean := coalesce(a_skip_leading_delimiter = 'Y',false);
    l_result                 ut_varchar2_list := ut_varchar2_list();
  begin
    if a_string is null then
      return l_result;
    end if;
    if a_delimiter is null then
      return ut_varchar2_list(a_string);
    end if;

    loop
      l_delimiter_position := instr(a_string, a_delimiter, l_offset);
      if not (l_delimiter_position = 1 and l_skip_leading_delimiter) then
        l_result.extend;
        if l_delimiter_position > 0 then
          l_result(l_result.last) := substr(a_string, l_offset, l_delimiter_position - l_offset);
        else
          l_result(l_result.last) := substr(a_string, l_offset);
        end if;
      end if;
      exit when l_delimiter_position = 0;
      l_offset := l_delimiter_position + 1;
    end loop;
    return l_result;
  end;

  function clob_to_table(a_clob clob, a_max_amount integer := 8191, a_delimiter varchar2:= chr(10)) return ut_varchar2_list is
    l_offset         integer := 1;
    l_length         integer := dbms_lob.getlength(a_clob);
    l_amount         integer;
    l_buffer         varchar2(32767);
    l_last_line      varchar2(32767);
    l_string_results ut_varchar2_list;
    l_results        ut_varchar2_list := ut_varchar2_list();
    l_has_last_line  boolean;
    l_skip_leading_delimiter varchar2(1) := 'N';
  begin
    while l_offset <= l_length loop
      l_amount := a_max_amount - coalesce( length(l_last_line), 0 );
--      dbms_lob.read(a_clob, l_amount, l_offset, l_buffer);
      l_buffer := substr(a_clob, l_offset, l_amount);
      l_amount := length(l_buffer);
      l_offset := l_offset + l_amount;

      l_string_results := string_to_table( l_last_line || l_buffer, a_delimiter, l_skip_leading_delimiter );
      for i in 1 .. l_string_results.count loop
        --if a split of lines was not done or not at the last line
        if l_string_results.count = 1 or i < l_string_results.count then
          l_results.extend;
          l_results(l_results.last) := l_string_results(i);
        end if;
      end loop;

      --check if we need to append the last line to the next element
      if l_string_results.count = 1 then
        l_has_last_line := false;
        l_last_line := null;
      elsif l_string_results.count > 1 then
        l_has_last_line := true;
        l_last_line := l_string_results(l_string_results.count);
      end if;

      l_skip_leading_delimiter := 'Y';
    end loop;
    if l_has_last_line then
      l_results.extend;
      l_results(l_results.last) := l_last_line;
    end if;
    return l_results;
  end;

  function table_to_clob(a_text_table ut_varchar2_list, a_delimiter varchar2:= chr(10)) return clob is
    l_result     clob;
    l_table_rows integer := coalesce(cardinality(a_text_table),0);
  begin
    for i in 1 .. l_table_rows loop
      if i < l_table_rows then
        append_to_clob(l_result, a_text_table(i)||a_delimiter);
      else
        append_to_clob(l_result, a_text_table(i));
      end if;
    end loop;
    return l_result;
  end;

  function table_to_clob(a_text_table ut_varchar2_rows, a_delimiter varchar2:= chr(10)) return clob is
    l_result     clob;
    l_table_rows integer := coalesce(cardinality(a_text_table),0);
  begin
    for i in 1 .. l_table_rows loop
      if i < l_table_rows then
        append_to_clob(l_result, a_text_table(i)||a_delimiter);
      else
        append_to_clob(l_result, a_text_table(i));
      end if;
    end loop;
    return l_result;
  end;

  function table_to_clob(a_integer_table ut_integer_list, a_delimiter varchar2:= chr(10)) return clob is
    l_result     clob;
    l_table_rows integer := coalesce(cardinality(a_integer_table),0);
  begin
    for i in 1 .. l_table_rows loop
      if i < l_table_rows then
        append_to_clob(l_result, a_integer_table(i)||a_delimiter);
      else
        append_to_clob(l_result, a_integer_table(i));
      end if;
    end loop;
    return l_result;
  end;

  function time_diff(a_start_time timestamp with time zone, a_end_time timestamp with time zone) return number is
  begin
    return
      extract(day from(a_end_time - a_start_time)) * 24 * 60 * 60 +
      extract(hour from(a_end_time - a_start_time)) * 60 * 60 +
      extract(minute from(a_end_time - a_start_time)) * 60 +
      extract(second from(a_end_time - a_start_time));
  end;

  function indent_lines(a_text varchar2, a_indent_size integer := 4, a_include_first_line boolean := false) return varchar2 is
  begin
    if a_include_first_line then
      return rtrim(lpad( ' ', a_indent_size ) || replace( a_text, chr(10), chr(10) || lpad( ' ', a_indent_size ) ));
    else
      return rtrim(replace( a_text, chr(10), chr(10) || lpad( ' ', a_indent_size ) ));
    end if;
  end;

  function get_utplsql_objects_list return ut_object_names is
    l_result ut_object_names;
  begin
    select distinct ut_object_name(sys_context('userenv','current_user'), o.object_name)
      bulk collect into l_result
      from user_objects o
     where o.object_name = 'UT' or object_name like 'UT\_%' escape '\'
       and o.object_type <> 'SYNONYM';
    return l_result;
  end;

  procedure append_to_list(a_list in out nocopy ut_varchar2_list, a_item varchar2) is
  begin
    if a_item is not null then
      if a_list is null then
        a_list := ut_varchar2_list();
      end if;
      a_list.extend;
      a_list(a_list.last) := a_item;
    end if;
  end append_to_list;

  procedure append_to_list(a_list in out nocopy ut_varchar2_rows, a_items ut_varchar2_rows) is
  begin
    if a_items is not null then
      if a_list is null then
        a_list := ut_varchar2_rows();
      end if;
      for i in 1 .. a_items.count loop
        a_list.extend;
        a_list(a_list.last) := a_items(i);
      end loop;
    end if;
  end;

  procedure append_to_list(a_list in out nocopy ut_varchar2_rows, a_item clob) is
  begin
    append_to_list(
      a_list,
      convert_collection(
        clob_to_table( a_item, ut_utils.gc_max_storage_varchar2_len )
      )
    );
  end;

  procedure append_to_list(a_list in out nocopy ut_varchar2_rows, a_item varchar2) is
  begin
    if a_item is not null then
      if a_list is null then
        a_list := ut_varchar2_rows();
      end if;
      if length(a_item) > gc_max_storage_varchar2_len then
        append_to_list(
          a_list,
          ut_utils.convert_collection(
            ut_utils.clob_to_table( a_item, gc_max_storage_varchar2_len )
          )
        );
      else
        a_list.extend;
        a_list(a_list.last) := a_item;
      end if;
    end if;
  end append_to_list;

  procedure append_to_clob(a_src_clob in out nocopy clob, a_clob_table t_clob_tab, a_delimiter varchar2:= chr(10)) is
  begin
    if a_clob_table is not null and cardinality(a_clob_table) > 0 then
      if a_src_clob is null then
        dbms_lob.createtemporary(a_src_clob, true);
      end if;
      for i in 1 .. a_clob_table.count loop
        dbms_lob.append(a_src_clob,a_clob_table(i));
        if i < a_clob_table.count then
          append_to_clob(a_src_clob,a_delimiter);
        end if;
      end loop;
    end if;
  end;

  procedure append_to_clob(a_src_clob in out nocopy clob, a_new_data clob) is
  begin
    if a_new_data is not null and dbms_lob.getlength(a_new_data) > 0 then
      if a_src_clob is null then
        dbms_lob.createtemporary(a_src_clob, true);
      end if;
      dbms_lob.append(a_src_clob, a_new_data);
    end if;
  end;

  procedure append_to_clob(a_src_clob in out nocopy clob, a_new_data varchar2) is
  begin
    if a_new_data is not null then
      if a_src_clob is null then
        dbms_lob.createtemporary(a_src_clob, true);
      end if;
      dbms_lob.writeappend(a_src_clob, dbms_lob.getlength(a_new_data), a_new_data);
    end if;
  end;

  function convert_collection(a_collection ut_varchar2_list) return ut_varchar2_rows is
    l_result ut_varchar2_rows;
  begin
    if a_collection is not null then
      l_result := ut_varchar2_rows();
      for i in 1 .. a_collection.count loop
        l_result.extend();
        l_result(i) := substr(a_collection(i),1,gc_max_storage_varchar2_len);
      end loop;
    end if;
    return l_result;
  end;

  function to_xpath(a_list varchar2, a_ancestors varchar2 := '/*/') return varchar2 is
    l_xpath varchar2(32767) := a_list;
  begin
    l_xpath := to_xpath( clob_to_table(a_clob=>a_list, a_delimiter=>','), a_ancestors);
    return l_xpath;
  end;

  function to_xpath(a_list ut_varchar2_list, a_ancestors varchar2 := '/*/') return varchar2 is
    l_xpath varchar2(32767);
    l_item  varchar2(32767);
    l_iter  integer;
  begin
    if a_list is not null then
      l_iter := a_list.first;
      while l_iter is not null loop
        l_item := trim(a_list(l_iter));
        if l_item is not null then
          if l_item like '%,%' then
            l_xpath := l_xpath || to_xpath( l_item, a_ancestors ) || '|';
          elsif l_item like '/%' then
            l_xpath := l_xpath || l_item || '|';
          else
            l_xpath := l_xpath || a_ancestors || l_item || '|';
          end if;
        end if;
        l_iter := a_list.next(l_iter);
      end loop;
      l_xpath := rtrim(l_xpath,',|');
    end if;
    return l_xpath;
  end;

  procedure cleanup_session_temp_tables is
  begin
    execute immediate 'truncate table dbmspcc_blocks';
    execute immediate 'truncate table dbmspcc_units';
    execute immediate 'truncate table dbmspcc_runs';
  end;

  function to_version(a_version_no varchar2) return t_version is
    l_result             t_version;
    c_version_part_regex constant varchar2(20) := '[0-9]+';
  begin

    if regexp_like(a_version_no,'v?([0-9]+(\.|$)){1,4}') then
      l_result.major  := regexp_substr(a_version_no, c_version_part_regex, 1, 1);
      l_result.minor  := regexp_substr(a_version_no, c_version_part_regex, 1, 2);
      l_result.bugfix := regexp_substr(a_version_no, c_version_part_regex, 1, 3);
      l_result.build  := regexp_substr(a_version_no, c_version_part_regex, 1, 4);
    else
      raise_application_error(gc_invalid_version_no, 'Version string "'||a_version_no||'" is not a valid version');
    end if;
    return l_result;
  end;

  procedure save_dbms_output_to_cache is
    l_status number;
    l_line   varchar2(32767);
    l_offset integer := 0;
    l_lines  ut_varchar2_rows := ut_varchar2_rows();
    c_lines_limit constant integer := 100;
    pragma autonomous_transaction;

    procedure flush_lines(a_lines ut_varchar2_rows, a_offset integer) is
    begin
      insert into ut_dbms_output_cache (seq_no,text)
        select rownum+a_offset, column_value
        from table(a_lines);
    end;
  begin
    loop
      dbms_output.get_line(line => l_line, status => l_status);
      exit when l_status = 1;
      l_lines := l_lines multiset union all ut_utils.convert_collection(ut_utils.clob_to_table(l_line||chr(7),4000));
      if l_lines.count > c_lines_limit then
        flush_lines(l_lines, l_offset);
        l_offset := l_offset + l_lines.count;
        l_lines.delete;
      end if;
    end loop;
    flush_lines(l_lines, l_offset);
    commit;
  end;

  procedure read_cache_to_dbms_output is
    l_lines_data sys_refcursor;
    l_lines  ut_varchar2_rows;
    c_lines_limit constant integer := 1000;
    pragma autonomous_transaction;
  begin
    open l_lines_data for select text from ut_dbms_output_cache order by seq_no;
    loop
      fetch l_lines_data bulk collect into l_lines limit c_lines_limit;
      for i in 1 .. l_lines.count loop
        if substr(l_lines(i),-1) = chr(7) then
          dbms_output.put_line(rtrim(l_lines(i),chr(7)));
        else
          dbms_output.put(l_lines(i));
        end if;
      end loop;
      exit when l_lines_data%notfound;
    end loop;
    execute immediate 'truncate table ut_dbms_output_cache';
    commit;
  end;

  function ut_owner return varchar2 is
  begin
    return qualified_sql_name( sys_context('userenv','current_schema') );
  end;

  function scale_cardinality(a_cardinality natural) return natural is
  begin
    return case when a_cardinality > 0 then trunc(power(10,(floor(log(10,a_cardinality))+1))/3) else 1 end;
  end;

  function build_depreciation_warning(a_old_syntax varchar2, a_new_syntax varchar2) return varchar2 is
  begin
    return 'The syntax: "'||a_old_syntax||'" is deprecated.' ||chr(10)||
           'Please use the new syntax: "'||a_new_syntax||'".' ||chr(10)||
           'The deprecated syntax will not be supported in future releases.';
  end;

  function to_xml_number_format(a_value number) return varchar2 is
  begin
    return to_char(a_value, gc_number_format, 'NLS_NUMERIC_CHARACTERS=''. ''');
  end;

  function get_xml_header(a_encoding varchar2) return varchar2 is
  begin
    return
      '<?xml version="1.0"'
      ||case
          when a_encoding is not null
          then ' encoding="'||upper(a_encoding)||'"'
        end
      ||'?>';
  end;

  function trim_list_elements(a_list ut_varchar2_list, a_regexp_to_trim varchar2 default '[:space:]') return ut_varchar2_list is
    l_trimmed_list ut_varchar2_list;
    l_index integer;
  begin
    if a_list is not null then
      l_trimmed_list := ut_varchar2_list();
      l_index := a_list.first;

      while (l_index is not null) loop
        l_trimmed_list.extend;
        l_trimmed_list(l_trimmed_list.count) := regexp_replace(a_list(l_index), '(^['||a_regexp_to_trim||']*)|(['||a_regexp_to_trim||']*$)');
        l_index := a_list.next(l_index);
      end loop;
    end if;

    return l_trimmed_list;
  end;

  function filter_list(a_list in ut_varchar2_list, a_regexp_filter in varchar2) return ut_varchar2_list is
    l_filtered_list ut_varchar2_list;
    l_index integer;
  begin
    if a_list is not null then
      l_filtered_list := ut_varchar2_list();
      l_index := a_list.first;
      while (l_index is not null) loop
        if regexp_like(a_list(l_index), a_regexp_filter) then
          l_filtered_list.extend;
          l_filtered_list(l_filtered_list.count) := a_list(l_index);
        end if;
        l_index := a_list.next(l_index);
      end loop;
    end if;

    return l_filtered_list;
  end;

  function xmlgen_escaped_string(a_string in varchar2) return varchar2 is
    l_result varchar2(4000) := a_string;
    l_sql varchar2(32767) := q'!select q'[!'||a_string||q'!]' as "!'||a_string||'" from dual';
  begin
    if a_string is not null then
      select extract(dbms_xmlgen.getxmltype(l_sql),'/*/*/*').getRootElement()
      into l_result
      from dual;
    end if;
    return l_result;
  end;

  function replace_multiline_comments(a_source clob) return clob is
    l_result                  clob;
    l_ml_comment_start        binary_integer := 1;
    l_comment_start           binary_integer := 1;
    l_text_start              binary_integer := 1;
    l_escaped_text_start      binary_integer := 1;
    l_escaped_text_end_char   varchar2(1 char);
    l_end                     binary_integer := 1;
    l_ml_comment              clob;
    l_newlines_count          binary_integer;
    l_offset                  binary_integer := 1;
    l_length                  binary_integer := coalesce(dbms_lob.getlength(a_source), 0);
  begin
    l_ml_comment_start := instr(a_source,'/*');
    l_comment_start := instr(a_source,'--');
    l_text_start := instr(a_source,'''');
    l_escaped_text_start := instr(a_source,q'[q']');
    while l_offset > 0 and l_ml_comment_start > 0 loop

      if l_ml_comment_start > 0 and (l_ml_comment_start < l_comment_start or l_comment_start = 0)
        and (l_ml_comment_start < l_text_start or l_text_start = 0)and (l_ml_comment_start < l_escaped_text_start or l_escaped_text_start = 0)
      then
        l_end := instr(a_source,'*/',l_ml_comment_start+2);
        append_to_clob(l_result, dbms_lob.substr(a_source, l_ml_comment_start-l_offset, l_offset));
        if l_end > 0 then
          l_ml_comment     := substr(a_source, l_ml_comment_start, l_end-l_ml_comment_start);
          l_newlines_count := length( l_ml_comment ) - length( translate( l_ml_comment, 'a'||chr(10), 'a') );
          if l_newlines_count > 0 then
            append_to_clob(l_result, lpad( chr(10), l_newlines_count, chr(10) ) );
          end if;
          l_end := l_end + 2;
        end if;
      else

        if l_comment_start > 0 and (l_comment_start < l_ml_comment_start or l_ml_comment_start = 0)
           and (l_comment_start < l_text_start or l_text_start = 0) and (l_comment_start < l_escaped_text_start or l_escaped_text_start = 0)
        then
          l_end := instr(a_source,chr(10),l_comment_start+2);
          if l_end > 0 then
            l_end := l_end + 1;
          end if;
        elsif l_text_start > 0 and (l_text_start < l_ml_comment_start or l_ml_comment_start = 0)
              and (l_text_start < l_comment_start or l_comment_start = 0) and (l_text_start < l_escaped_text_start or l_escaped_text_start = 0)
        then
          l_end := instr(a_source,q'[']',l_text_start+1);

          --skip double quotes while searching for end of quoted text
          while l_end > 0 and l_end = instr(a_source,q'['']',l_text_start+1) loop
            l_end := instr(a_source,q'[']',l_end+1);
          end loop;
          if l_end > 0 then
            l_end := l_end + 1;
          end if;

        elsif l_escaped_text_start > 0 and (l_escaped_text_start < l_ml_comment_start or l_ml_comment_start = 0)
              and (l_escaped_text_start < l_comment_start or l_comment_start = 0) and (l_escaped_text_start < l_text_start or l_text_start = 0)
        then
          --translate char "[" from the start of quoted text  "q'[someting]'" into "]"
          l_escaped_text_end_char := translate( substr(a_source, l_escaped_text_start + 2, 1), '[{(<', ']})>');
          l_end := instr(a_source,l_escaped_text_end_char||'''',l_escaped_text_start + 3 );
          if l_end > 0 then
            l_end := l_end + 2;
          end if;
        end if;

        if l_end = 0 then
          append_to_clob(l_result, substr(a_source, l_offset, l_length-l_offset));
        else
          append_to_clob(l_result, substr(a_source, l_offset, l_end-l_offset));
        end if;
      end if;
      l_offset := l_end;
      if l_offset >= l_ml_comment_start then
        l_ml_comment_start := instr(a_source,'/*',l_offset);
      end if;
      if l_offset >= l_comment_start then
        l_comment_start := instr(a_source,'--',l_offset);
      end if;
      if l_offset >= l_text_start then
        l_text_start := instr(a_source,'''',l_offset);
      end if;
      if l_offset >= l_escaped_text_start then
        l_escaped_text_start := instr(a_source,q'[q']',l_offset);
      end if;
    end loop;
    append_to_clob(l_result, substr(a_source, l_end));
    return l_result;
  end;

  function get_child_reporters(a_for_reporters ut_reporters_info := null) return ut_reporters_info is
    l_for_reporters ut_reporters_info := a_for_reporters;
    l_results       ut_reporters_info;
  begin
    if l_for_reporters is null then
      l_for_reporters := ut_reporters_info(ut_reporter_info('UT_REPORTER_BASE','N','N','N'));
    end if;
    
    select /*+ cardinality(f 10) */
      ut_reporter_info(
        object_name => t.type_name,
        is_output_reporter =>
          case
            when f.is_output_reporter = 'Y' or t.type_name = 'UT_OUTPUT_REPORTER_BASE'
            then 'Y' else 'N'
          end,
        is_instantiable => case when t.instantiable = 'YES' then 'Y' else 'N' end,
        is_final => case when t.final = 'YES' then 'Y' else 'N' end
      )
    bulk collect into l_results
    from user_types t
    join (select * from table(l_for_reporters) where is_final = 'N' ) f
      on f.object_name = supertype_name;

    return l_results;
  end;

  function remove_error_from_stack(a_error_stack varchar2, a_ora_code number) return varchar2 is
    l_caller_stack_line          varchar2(4000);
    l_ora_search_pattern         varchar2(500) := '^ORA'||a_ora_code||': (.*)$';
  begin
   l_caller_stack_line := regexp_replace(srcstr     => a_error_stack
                          ,pattern    => l_ora_search_pattern
                          ,replacestr => null
                          ,position   => 1
                          ,occurrence => 1
                          ,modifier   => 'm');
   return l_caller_stack_line;
  end;
 
  /**
  * Change string into unicode to match xmlgen format _00<unicode>_
  * https://docs.oracle.com/en/database/oracle/oracle-database/12.2/adxdb/generation-of-XML-data-from-relational-data.html#GUID-5BE09A7D-80D8-4734-B9AF-4A61F27FA9B2
  * secion v3.1.9.3253-develop
  */  
  function char_to_xmlgen_unicode(a_character varchar2) return varchar2 is
  begin
    return '_x00'||rawtohex(utl_raw.cast_to_raw(a_character))||'_';
  end;
  
  /**
  * Build valid XML column name as element names can contain letters, digits, hyphens, underscores, and periods
  */  
  function build_valid_xml_name(a_preprocessed_name varchar2) return varchar2 is
    l_post_processed varchar2(4000);
  begin
    for i in (select regexp_substr( a_preprocessed_name ,'(.{1})', 1, level, null, 1 ) AS string_char,level level_no
              from   dual connect by level <= regexp_count(a_preprocessed_name, '(.{1})'))
    loop
      if i.level_no = 1 and regexp_like(i.string_char,gc_invalid_first_xml_char) then
        l_post_processed := l_post_processed || char_to_xmlgen_unicode(i.string_char);
      elsif regexp_like(i.string_char,gc_invalid_xml_char) then
        l_post_processed := l_post_processed || char_to_xmlgen_unicode(i.string_char);
      else
        l_post_processed := l_post_processed || i.string_char;
      end if;
    end loop;
    return l_post_processed;  
  end;
  
  function get_valid_xml_name(a_name varchar2) return varchar2 is
    l_valid_name varchar2(4000);
  begin
    if regexp_like(a_name,gc_full_valid_xml_name) then
      l_valid_name := a_name;
    else
      l_valid_name := build_valid_xml_name(a_name);
    end if;
    return l_valid_name;
  end;

  function to_cdata(a_lines ut_varchar2_rows) return ut_varchar2_rows is
    l_results ut_varchar2_rows;
  begin
    if a_lines is not empty then
      ut_utils.append_to_list( l_results, gc_cdata_start_tag);
      for i in 1 .. a_lines.count loop
        ut_utils.append_to_list( l_results, replace( a_lines(i), gc_cdata_end_tag, gc_cdata_end_tag_wrap ) );
      end loop;
      ut_utils.append_to_list( l_results, gc_cdata_end_tag);
    else
      l_results := a_lines;
    end if;
    return l_results;
  end;

  function to_cdata(a_clob clob) return clob is
    l_result clob;
  begin
    if a_clob is not null and a_clob != empty_clob() then
      l_result := replace( a_clob, gc_cdata_end_tag, gc_cdata_end_tag_wrap );
    else
      l_result := a_clob;
    end if;
    return l_result;
  end;

  function add_prefix(a_list ut_varchar2_list, a_prefix varchar2, a_connector varchar2 := '/') return ut_varchar2_list is
    l_result ut_varchar2_list := ut_varchar2_list();
    l_idx binary_integer;
  begin
    if a_prefix is not null then
      l_idx := a_list.first;
      while l_idx is not null loop
        l_result.extend;
        l_result(l_idx) := add_prefix(a_list(l_idx), a_prefix, a_connector);
        l_idx := a_list.next(l_idx);
      end loop;
    end if;
      return l_result;
  end;

  function add_prefix(a_item varchar2, a_prefix varchar2, a_connector varchar2 := '/') return varchar2 is
  begin
    return a_prefix||a_connector||trim(leading a_connector from a_item);
  end;

  function strip_prefix(a_item varchar2, a_prefix varchar2, a_connector varchar2 := '/') return varchar2 is
  begin
    return regexp_replace(a_item,a_prefix||a_connector);
  end;

  function get_hash(a_data raw, a_hash_type binary_integer := dbms_crypto.hash_sh1) return t_hash is
  begin
    return dbms_crypto.hash(a_data, a_hash_type);
  end;

  function get_hash(a_data clob, a_hash_type binary_integer := dbms_crypto.hash_sh1) return t_hash is
  begin
    return dbms_crypto.hash(a_data, a_hash_type);
  end;

  function qualified_sql_name(a_name varchar2) return varchar2 is
  begin
    return
        case
          when a_name is not null
          then sys.dbms_assert.qualified_sql_name(a_name)
        end;
  end;

end ut_utils;
/
