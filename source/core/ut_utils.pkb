create or replace package body ut_utils is
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

  function surround_with(a_value varchar2, a_quote_char varchar2) return varchar2 is
  begin
    return case when a_quote_char is not null then a_quote_char||a_value||a_quote_char else a_value end;
  end;

  function test_result_to_char(a_test_result integer) return varchar2 as
    l_result varchar2(20);
  begin
    if a_test_result = tr_success then
      l_result := tr_success_char;
    elsif a_test_result = tr_failure then
      l_result := tr_failure_char;
    elsif a_test_result = tr_error then
      l_result := tr_error_char;
    elsif a_test_result = tr_disabled then
      l_result := tr_disabled_char;
    else
      l_result := 'Unknown(' || coalesce(to_char(a_test_result),'NULL') || ')';
    end if ;
    return l_result;
  end test_result_to_char;


  function to_test_result(a_test boolean) return integer is
    l_result integer;
  begin
    if a_test then
      l_result := tr_success;
    else
      l_result := tr_failure;
    end if;
    return l_result;
  end;

  function gen_savepoint_name return varchar2 is
  begin
    return 'ut_'||to_char(systimestamp,'yymmddhh24mmssff');
  end;

  /*
   Procedure: validate_rollback_type

   Validates passed value against supported rollback types
  */
  procedure validate_rollback_type(a_rollback_type number) is
  begin
    if a_rollback_type not in (gc_rollback_auto, gc_rollback_manual) then
      raise_application_error(-20200,'Rollback type is not supported');
    end if;
  end validate_rollback_type;

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

  function to_string(a_value varchar2, a_qoute_char varchar2 := '''') return varchar2 is
    l_len integer := coalesce(length(a_value),0);
    l_result varchar2(32767);
  begin
    if l_len = 0 then
      l_result := gc_null_string;
    elsif l_len <= gc_max_input_string_length then
      l_result := surround_with(a_value, a_qoute_char);
    else
      l_result := surround_with(substr(a_value,1,gc_overflow_substr_len),a_qoute_char) || gc_more_data_string;
    end if ;
    return l_result;
  end;

  function to_string(a_value clob, a_qoute_char varchar2 := '''') return varchar2 is
    l_len integer := coalesce(dbms_lob.getlength(a_value), 0);
    l_result varchar2(32767);
  begin
    if l_len = 0 then
      l_result := gc_null_string;
    elsif l_len <= gc_max_input_string_length then
      l_result := surround_with(a_value,a_qoute_char);
    else
      l_result := surround_with(dbms_lob.substr(a_value, gc_overflow_substr_len),a_qoute_char) || gc_more_data_string;
    end if;
    return l_result;
  end;

  function to_string(a_value blob, a_qoute_char varchar2 := '''') return varchar2 is
    l_len integer := coalesce(dbms_lob.getlength(a_value), 0);
    l_result varchar2(32767);
  begin
    if l_len = 0 then
      l_result := gc_null_string;
    elsif l_len <= gc_max_input_string_length then
      l_result := surround_with(rawtohex(a_value),a_qoute_char);
    else
      l_result := to_string( rawtohex(dbms_lob.substr(a_value, gc_overflow_substr_len)) );
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
      dbms_lob.read(a_clob, l_amount, l_offset, l_buffer);
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
    l_result          clob;
    l_text_table_rows integer := coalesce(cardinality(a_text_table),0);
  begin
    for i in 1 .. l_text_table_rows loop
      if i < l_text_table_rows then
        append_to_clob(l_result, a_text_table(i)||a_delimiter);
      else
        append_to_clob(l_result, a_text_table(i));
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

  procedure append_to_varchar2_list(a_list in out nocopy ut_varchar2_list, a_line varchar2) is
  begin
    if a_line is not null then
      if a_list is null then
        a_list := ut_varchar2_list();
      end if;
      a_list.extend;
      a_list(a_list.last) := a_line;
    end if;
  end append_to_varchar2_list;

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
    if l_xpath not like '/%' then
      l_xpath := to_xpath( clob_to_table(a_clob=>a_list, a_delimiter=>','), a_ancestors);
    end if;
    return l_xpath;
  end;

  function to_xpath(a_list ut_varchar2_list, a_ancestors varchar2 := '/*/') return varchar2 is
    l_xpath varchar2(32767);
    l_item  varchar2(32767);
    i integer;
  begin
    i := a_list.first;
    while i is not null loop
      l_item := trim(a_list(i));
      if l_item is not null then
        l_xpath := l_xpath || a_ancestors ||a_list(i)||'|';
      end if;
      i := a_list.next(i);
    end loop;
    l_xpath := rtrim(l_xpath,',|');
    return l_xpath;
  end;

end ut_utils;
/
