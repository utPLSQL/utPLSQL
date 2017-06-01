create or replace package body ut_expectation_processor as
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

  type tt_nls_params is table of nls_session_parameters%rowtype;

  g_session_params tt_nls_params;

  g_expectations_called ut_expectation_results := ut_expectation_results();

  g_nulls_are_equal boolean_not_null := gc_default_nulls_are_equal;

  function nulls_are_equal return boolean is
  begin
    return g_nulls_are_equal;
  end;

  procedure nulls_are_equal(a_setting boolean_not_null) is
  begin
    g_nulls_are_equal := a_setting;
  end;

  function get_status return integer is
    l_result integer := ut_utils.tr_success;
  begin
    ut_utils.debug_log('ut_expectation_processor.get_status');

    for i in 1 .. g_expectations_called.count loop
      l_result := greatest(l_result, g_expectations_called(i).status);
      exit when l_result = ut_utils.tr_error;
    end loop;
    return l_result;
  end get_status;

  procedure clear_expectations is
  begin
    ut_utils.debug_log('ut_expectation_processor.clear_expectations');
    g_expectations_called.delete;
  end;

  function get_expectations_results return ut_expectation_results is
    l_expectations_results ut_expectation_results := ut_expectation_results();
  begin
    ut_utils.debug_log('ut_expectation_processor.get_expectations_results: .count='||g_expectations_called.count);
    l_expectations_results := g_expectations_called;
    clear_expectations();
    return l_expectations_results;
  end get_expectations_results;

  procedure add_expectation_result(a_expectation_result ut_expectation_result) is
  begin
    ut_utils.debug_log('ut_expectation_processor.add_expectation_result');
    g_expectations_called.extend;
    g_expectations_called(g_expectations_called.last) := a_expectation_result;
  end;

  procedure report_failure(a_message in varchar2) is
  begin
    add_expectation_result(ut_expectation_result(ut_utils.tr_failure, null, a_message));
  end;

  function get_session_parameters return tt_nls_params is
    l_session_params tt_nls_params;
  begin
    select nsp.parameter, nsp.value
      bulk collect into l_session_params
     from nls_session_parameters nsp
    where parameter
       in ( 'NLS_DATE_FORMAT', 'NLS_TIMESTAMP_FORMAT', 'NLS_TIMESTAMP_TZ_FORMAT');

    return l_session_params;
  end;

  procedure set_xml_nls_params is
    insuf_privs exception;
    pragma exception_init(insuf_privs, -1031);
  begin
    g_session_params := get_session_parameters();

    begin
      execute immediate q'[alter session set events '19119 trace name context forever, level 0x8']';
    exception
      when insuf_privs then NULL;
    end;

    execute immediate 'alter session set nls_date_format = '''||ut_utils.gc_date_format||'''';
    execute immediate 'alter session set nls_timestamp_format = '''||ut_utils.gc_timestamp_format||'''';
    execute immediate 'alter session set nls_timestamp_tz_format = '''||ut_utils.gc_timestamp_tz_format||'''';
  end;

  procedure reset_nls_params is
    insuf_privs exception;
    pragma exception_init(insuf_privs, -1031);
  begin
    begin
      execute immediate q'[alter session set events '19119 trace name context off']';
    exception
    when insuf_privs then NULL;
    end;

    if g_session_params is not null then
      for i in 1 .. g_session_params.count loop
        execute immediate 'alter session set '||g_session_params(i).parameter||' = '''||g_session_params(i).value||'''';
      end loop;
    end if;

  end;

  function who_called_expectation return varchar2 is
    c_call_stack                 constant varchar2(32767) := dbms_utility.format_call_stack();
    l_caller_stack_line          varchar2(4000);
    l_caller_type_and_name       varchar2(4000);
    l_line_no                    integer;
    l_owner                      varchar2(1000);
    l_object_name                varchar2(1000);   
    -- in 12.2 format_call_stack reportes not only package name, but also the procedure name
    -- when 11g and 12c reports only package name
    c_expectation_search_pattern constant varchar2(500) := '(.*\.UT_EXPECTATION_RESULT\s+)(.*\.UT_EXPECTATION[A-Z0-9#_$]*(\.\w+)?.*\s+)+(.*)\s';
  begin
    l_caller_stack_line    := regexp_substr( c_call_stack, c_expectation_search_pattern, 1, 1, 'm', 4);
    l_line_no              := to_number( regexp_substr(l_caller_stack_line,'^\dx[0-9a-f]+\s+(\d+)',subexpression => 1) );
    l_caller_type_and_name    := substr( l_caller_stack_line, 23 );
    if l_caller_stack_line like '%.%' then
      l_owner       := regexp_substr(l_caller_stack_line,'\s(\w+)\.(\w|\.)+$',subexpression => 1);
      l_object_name := regexp_substr(l_caller_stack_line,'\s(\w+)\.((\w|\.)+)$',subexpression => 2);
    end if;
    return
      case when l_owner is not null and l_object_name is not null and l_line_no is not null then
        'at "' || l_owner || '.' || l_object_name || '", line '|| l_line_no || ' ' ||
          ut_metadata.get_source_definition_line(l_owner, l_object_name, l_line_no)
      end;
  end;
end;
/
