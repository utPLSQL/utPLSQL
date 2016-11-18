create or replace package body ut_utils is

  function quote_string(a_value varchar2) return varchar2 is
  begin
    return case when a_value is not null then ''''||a_value||'''' else gc_null_string end;
  end;

  function test_result_to_char(a_test_result integer) return varchar2 as
  begin
    return case a_test_result
                  when tr_success then tr_success_char
                  when tr_failure then tr_failure_char
                  when tr_error   then tr_error_char
                  when tr_ignore   then tr_ignore_char
                  else 'Unknown(' || coalesce(to_char(a_test_result),'NULL') || ')'
                end;
  end test_result_to_char;


  function to_test_result(a_test boolean) return integer is
  begin
    return case a_test
             when true then tr_success
             else tr_failure
           end;
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


  function to_string(a_value varchar2) return varchar2 is
    l_len integer := coalesce(length(a_value),0);
  begin
    return
      case
        when l_len = 0 then gc_null_string
        when l_len <= gc_max_input_string_length then quote_string(a_value)
        else quote_string(substr(a_value,1,gc_overflow_substr_len)) || gc_more_data_string
      end;
  end;

  function to_string(a_value clob) return varchar2 is
    l_len integer := coalesce(dbms_lob.getlength(a_value), 0);
  begin
    return
      case
        when l_len = 0 then gc_null_string
        when l_len <= gc_max_input_string_length then quote_string(a_value)
        else quote_string(dbms_lob.substr(a_value, gc_overflow_substr_len)) || gc_more_data_string
      end;
  end;

  function to_string(a_value blob) return varchar2 is
    l_len integer := coalesce(dbms_lob.getlength(a_value), 0);
  begin
    return
      case
        when l_len = 0 then gc_null_string
        when l_len <= gc_max_input_string_length then quote_string(rawtohex(a_value))
        else to_string( rawtohex(dbms_lob.substr(a_value, gc_overflow_substr_len)) )
      end;
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


  function boolean_to_int(a_value boolean) return integer is
  begin
    return case a_value when true then 1 when false then 0 end;
  end;

  function int_to_boolean(a_value integer) return boolean is
  begin
    return case a_value when 1 then true when 0 then false end;
  end;

  function string_to_table(a_string varchar2, a_delimiter varchar2:= chr(10)) return ut_output_varchar2_list is
    l_offset             integer := 1;
    l_length             integer;
    l_result             ut_output_varchar2_list := ut_output_varchar2_list();
    l_delimiter_position integer;
  begin
    if a_string is not null then
      l_length := length(a_string);
      loop
        l_result.extend;
        l_delimiter_position := instr(a_string, a_delimiter, l_offset);
        if l_delimiter_position > 0 then
          l_result(l_result.last) := substr(a_string, l_offset, l_delimiter_position - l_offset);
        else
          l_result(l_result.last) := substr(a_string, l_offset);
        end if;
        exit when l_delimiter_position = 0;
        l_offset := l_delimiter_position + 1;
      end loop;
    end if;
    return l_result;
  end;

  function clob_to_table(a_clob clob, a_delimiter varchar2:= chr(10), a_max_amount integer := 32767) return ut_output_varchar2_list pipelined is
    l_offset    integer := 1;
    l_length    integer := dbms_lob.getlength(a_clob);
    l_amount    integer := a_max_amount;
    l_buffer    varchar2(32767);
    l_last_line varchar2(32767);
    l_results ut_output_varchar2_list;
    l_is_last_line boolean;
  begin
    while l_offset <= l_length loop
      l_amount := a_max_amount - coalesce( length(l_last_line), 0 );
      dbms_lob.read(a_clob, l_amount, l_offset, l_buffer);
      l_offset := l_offset + l_amount;

      l_results := string_to_table( l_last_line || l_buffer, a_delimiter );
      l_is_last_line := false;
      for i in 1 .. l_results.count loop
        if i < l_results.count or l_results.count = 1 then
          pipe row( l_results(i) );
        else
          l_is_last_line := true;
          l_last_line := l_results(i);
        end if;
      end loop;
    end loop;
    if l_is_last_line then
      pipe row( l_last_line );
    end if;
    return;
  end;

end;
/
