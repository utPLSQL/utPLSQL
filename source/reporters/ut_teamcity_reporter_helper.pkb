create or replace package body ut_teamcity_reporter_helper is
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

  subtype t_prop_index is varchar2(2000 char);
  type t_props is table of varchar2(32767) index by t_prop_index;

  function escape_value(a_value in varchar2) return varchar2 is
  begin
    return regexp_replace(a_value, '(''|"|' || chr(13) || '|' || chr(10) || '|[|])', '|\1');
  end;

  function message(a_command in varchar2, a_props t_props default cast(null as t_props)) return varchar2 is
    l_message varchar2(32767);
    l_index   t_prop_index;
    l_value   varchar2(32767);
  begin
    l_message := '##teamcity[' || a_command || ' timestamp=''' ||
                 regexp_replace(to_char(systimestamp, 'YYYY-MM-DD"T"HH24:MI:ss.FFTZHTZM'), '(\.\d{3})\d+(\+)', '\1\2') || '''';

    l_index := a_props.first;
    while l_index is not null loop
      if a_props(l_index) is not null then
        l_value   := escape_value(a_props(l_index));
        l_message := l_message || ' ' || l_index || '=''' || l_value || '''';
      end if;
      l_index := a_props.next(l_index);
    end loop;
    l_message := l_message || ']';
    return l_message;

  end message;

  function block_opened(a_name varchar2, a_flow_id varchar2 default null) return varchar2 is
    l_props t_props;
  begin
    l_props('name') := a_name;
    l_props('flowId') := a_flow_id;
    return message('blockOpened', l_props);
  end;

  function block_closed(a_name varchar2, a_flow_id varchar2 default null) return varchar2 is
    l_props t_props;
  begin
    l_props('name') := a_name;
    l_props('flowId') := a_flow_id;
    return message('blockClosed', l_props);
  end;

  function test_suite_started(a_suite_name varchar2, a_flow_id varchar2 default null) return varchar2 is
    l_props t_props;
  begin
    l_props('name') := a_suite_name;
    l_props('flowId') := a_flow_id;
    return message('testSuiteStarted', l_props);
  end;
  function test_suite_finished(a_suite_name varchar2, a_flow_id varchar2 default null) return varchar2 is
    l_props t_props;
  begin
    l_props('name') := a_suite_name;
    l_props('flowId') := a_flow_id;
    return message('testSuiteFinished', l_props);
  end;

  function test_started(a_test_name varchar2, a_capture_standard_output boolean default null, a_flow_id varchar2 default null) return varchar2 is
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
    return message('testStarted', l_props);
  end;

  function test_finished(a_test_name varchar2, a_test_duration_milisec number default null, a_flow_id varchar2 default null) return varchar2 is
    l_props t_props;
  begin
    l_props('name') := a_test_name;
    l_props('duration') := a_test_duration_milisec;
    l_props('flowId') := a_flow_id;
    return message('testFinished', l_props);
  end;

  function test_ignored(a_test_name varchar2, a_flow_id varchar2 default null) return varchar2 is
    l_props t_props;
  begin
    l_props('name') := a_test_name;
    l_props('flowId') := a_flow_id;
    return message('testIgnored', l_props);
  end;
  function test_failed(a_test_name varchar2, a_msg in varchar2 default null, a_details varchar2 default null, a_flow_id varchar2 default null, a_actual varchar2 default null, a_expected varchar2 default null) return varchar2 is
    l_props t_props;
  begin
    l_props('name') := a_test_name;
    l_props('message') := a_msg;
    l_props('details') := a_details;
    l_props('flowId') := a_flow_id;

    if a_actual is not null and a_expected is not null then
      l_props('actual') := a_actual;
      l_props('expected') := a_expected;
    end if;

    return message('testFailed', l_props);
  end;
  function test_std_out(a_test_name varchar2, a_out in varchar2, a_flow_id in varchar2 default null) return varchar2 is
    l_props t_props;
  begin
    l_props('name') := a_test_name;
    l_props('out') := a_out;
    l_props('flowId') := a_flow_id;
    return message('testStdOut', l_props);
  end;
  function test_std_err(a_test_name varchar2, a_out in varchar2, a_flow_id in varchar2 default null) return varchar2 is
    l_props t_props;
  begin
    l_props('name') := a_test_name;
    l_props('out') := a_out;
    l_props('flowId') := a_flow_id;
    return message('testStdErr', l_props);
  end;

  function custom_message(a_text in varchar2, a_status in varchar2, a_error_deatils in varchar2 default null, a_flow_id in varchar2 default null) return varchar2 is
    l_props t_props;
  begin
    l_props('text') := a_text;
    l_props('status') := a_status;
    l_props('errorDetails') := a_error_deatils;
    l_props('flowId') := a_flow_id;
    return message('message', l_props);
  end;

end ut_teamcity_reporter_helper;
/
