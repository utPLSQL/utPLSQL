create or replace package body ut_teamcity_reporter_printer is

  subtype t_prop_index is varchar2(2000 char);
  type t_props is table of varchar2(32767) index by t_prop_index;

  function escape_value(a_value in varchar2) return varchar2 is
  begin
    return regexp_replace(a_value, '(''|"|' || chr(13) || '|' || chr(10) || '|[|])', '|\1');
  end;

  procedure message(a_command in varchar2, a_props t_props default cast(null as t_props)) is
    l_message varchar2(32767);
    l_index   t_prop_index;
    l_value   varchar2(32767);
  begin
    l_message := '##teamcity[' || a_command || ' timestamp=''' ||
                 to_char(systimestamp, 'YYYY-MM-DD"T"HH24:MI:ss.FFTZHTZM') || '''';
  
    l_index := a_props.first;
    while l_index is not null loop
      if a_props(l_index) is not null then
        l_value   := escape_value(a_props(l_index));
        l_message := l_message || ' ' || l_index || '=''' || l_value || '''';
      end if;
      l_index := a_props.next(l_index);
    end loop;
    l_message := l_message || ']';
    sys.dbms_output.put_line(l_message);
  
  end message;

  procedure block_opened(a_name varchar2, a_flow_id varchar2 default null) is
    l_props t_props;
  begin
    l_props('name') := a_name;
    l_props('flowId') := a_flow_id;
    message('blockOpened', l_props);
  end;

  procedure block_closed(a_name varchar2, a_flow_id varchar2 default null) is
    l_props t_props;
  begin
    l_props('name') := a_name;
    l_props('flowId') := a_flow_id;
    message('blockClosed', l_props);
  end;

  procedure test_suite_started(a_suite_name varchar2, a_flow_id varchar2 default null) is
    l_props t_props;
  begin
    l_props('name') := a_suite_name;
    l_props('flowId') := a_flow_id;
    message('testSuiteStarted', l_props);
  end;
  procedure test_suite_finished(a_suite_name varchar2, a_flow_id varchar2 default null) is
    l_props t_props;
  begin
    l_props('name') := a_suite_name;
    l_props('flowId') := a_flow_id;
    message('testSuiteFinished', l_props);
  end;

  procedure test_started(a_test_name varchar2, a_capture_standard_output boolean default null, a_flow_id varchar2 default null) is
    l_props t_props;
  begin
    l_props('name') := a_test_name;
    l_props('captureStandardOutput') := case a_capture_standard_output
                                          when true then
                                           'true'
                                          when false then
                                           'false'
                                          else
                                           null
                                        end;
    l_props('flowId') := a_flow_id;
    message('testStarted', l_props);
  end;

  procedure test_finished(a_test_name varchar2, a_test_duration_milisec number default null, a_flow_id varchar2 default null) is
    l_props t_props;
  begin
    l_props('name') := a_test_name;
    l_props('duration') := a_test_duration_milisec;
    l_props('flowId') := a_flow_id;
    message('testFinished', l_props);
  end;

  procedure test_ignored(a_test_name varchar2, a_flow_id varchar2 default null) is
    l_props t_props;
  begin
    l_props('name') := a_test_name;
    l_props('flowId') := a_flow_id;
    message('testIgnored', l_props);
  end;
  procedure test_failed(a_test_name varchar2, a_msg in varchar2 default null, a_details varchar2 default null, a_flow_id varchar2 default null) is
    l_props t_props;
  begin
    l_props('name') := a_test_name;
    l_props('message') := a_msg;
    l_props('details') := a_details;
    l_props('flowId') := a_flow_id;
    message('testFailed', l_props);
  end;
  procedure test_std_out(a_test_name varchar2, a_out in varchar2, a_flow_id in varchar2 default null) is
    l_props t_props;
  begin
    l_props('name') := a_test_name;
    l_props('out') := a_out;
    l_props('flowId') := a_flow_id;
    message('testStdOut', l_props);
  end;
  procedure test_std_err(a_test_name varchar2, a_out in varchar2, a_flow_id in varchar2 default null) is
    l_props t_props;
  begin
    l_props('name') := a_test_name;
    l_props('out') := a_out;
    l_props('flowId') := a_flow_id;
    message('testStdErr', l_props);
  end;

  procedure custom_message(a_text in varchar2, a_status in varchar2, a_error_deatils in varchar2 default null, a_flow_id in varchar2 default null) is
    l_props t_props;
  begin
    l_props('text') := a_text;
    l_props('status') := a_status;
    l_props('errorDetails') := a_error_deatils;
    l_props('flowId') := a_flow_id;
    message('message', l_props);
  end;

end ut_teamcity_reporter_printer;
/
