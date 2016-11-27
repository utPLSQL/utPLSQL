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
        else quote_string( rawtohex(dbms_lob.substr(a_value, gc_overflow_substr_len)) )
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

  function time_diff(a_start_time timestamp with time zone, a_end_time timestamp with time zone) return number is
  begin
    return
      extract(day from(a_end_time - a_start_time)) * 24 * 60 * 60 +
      extract(hour from(a_end_time - a_start_time)) * 60 * 60 +
      extract(minute from(a_end_time - a_start_time)) * 60 +
      extract(second from(a_end_time - a_start_time));
  end;

  function indent_lines(a_text varchar2, a_indent_size integer) return varchar2 is
  begin
    return replace( a_text, chr(10), chr(10) || lpad( ' ', a_indent_size ) );
  end;

end ut_utils;
/
