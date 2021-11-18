create or replace package body ut_expectation_processor as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project

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

  g_warnings ut_varchar2_rows := ut_varchar2_rows();

  g_nulls_are_equal boolean_not_null := gc_default_nulls_are_equal;

  g_package_invalidated boolean := false;

  function nulls_are_equal return boolean is
  begin
    return g_nulls_are_equal;
  end;

  procedure nulls_are_equal(a_setting boolean_not_null) is
  begin
    g_nulls_are_equal := a_setting;
  end;

  function get_status return integer is
    l_result integer := ut_utils.gc_success;
  begin
    ut_utils.debug_log('ut_expectation_processor.get_status');

    for i in 1 .. g_expectations_called.count loop
      l_result := greatest(l_result, g_expectations_called(i).status);
      exit when l_result = ut_utils.gc_error;
    end loop;
    return l_result;
  end get_status;

  procedure clear_expectations is
  begin
    ut_utils.debug_log('ut_expectation_processor.clear_expectations');
    g_expectations_called.delete;
    g_warnings.delete;
  end;

  function get_all_expectations return ut_expectation_results is
  begin
    ut_utils.debug_log('ut_expectation_processor.get_all_expectations: g_expectations_called.count='||g_expectations_called.count);
    return g_expectations_called;
  end get_all_expectations;

  function get_failed_expectations return ut_expectation_results is
    l_expectations_results ut_expectation_results := ut_expectation_results();
  begin
    ut_utils.debug_log('ut_expectation_processor.get_failed_expectations: g_expectations_called.count='||g_expectations_called.count);
    for i in 1 .. g_expectations_called.count loop
      if g_expectations_called(i).status > ut_utils.gc_success then
        l_expectations_results.extend;
        l_expectations_results(l_expectations_results.last) := g_expectations_called(i);
      end if;
    end loop;
    ut_utils.debug_log('ut_expectation_processor.get_failed_expectations: l_expectations_results.count='||l_expectations_results.count);
    return l_expectations_results;
  end get_failed_expectations;

  procedure add_expectation_result(a_expectation_result ut_expectation_result) is
    l_results ut_varchar2_list;
  begin
    if ut_session_context.is_ut_run then
      ut_event_manager.trigger_event(ut_event_manager.gc_debug, a_expectation_result);
      g_expectations_called.extend;
      g_expectations_called(g_expectations_called.last) := a_expectation_result;
    else
      l_results := a_expectation_result.get_result_lines();
      dbms_output.put_line( upper( ut_utils.test_result_to_char( a_expectation_result.status ) ) || '');
      for i in 1 .. l_results.count loop
        dbms_output.put_line( '  ' || l_results(i) );
      end loop;
      if a_expectation_result.caller_info is not null then
        dbms_output.put_line( ut_utils.indent_lines( a_expectation_result.caller_info, 2, true) );
      end if;
    end if;
  end;

  procedure report_failure(a_message in varchar2) is
  begin
    add_expectation_result(ut_expectation_result(ut_utils.gc_failure, null, a_message));
  end;
  
  function get_session_parameters return tt_nls_params is
    l_session_params tt_nls_params;
  begin
    select /*+ no_parallel */ nsp.parameter, nsp.value
      bulk collect into l_session_params
     from nls_session_parameters nsp
    where parameter
       in ( 'NLS_DATE_FORMAT', 'NLS_TIMESTAMP_FORMAT', 'NLS_TIMESTAMP_TZ_FORMAT')
    order by 1;

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

  function who_called_expectation(a_call_stack varchar2) return varchar2 is
    l_caller_stack_line          varchar2(4000);
    l_call_stack                 varchar2(4000);
    l_line_no                    integer;
    l_owner                      varchar2(1000);
    l_object_name                varchar2(1000);
    l_result                     varchar2(4000);
    -- in 12.2 format_call_stack reportes not only package name, but also the procedure name
    -- when 11g and 12c reports only package name
    function cut_header_and_expectations( a_stack varchar2 ) return varchar2 is
    begin
      return regexp_substr( a_stack, '(.*\.(UT_EXPECTATION[A-Z0-9#_$]*|UT|UTASSERT2?)(\.[A-Z0-9#_$]+)?\s+)+((.|\s)*)', 1, 1, 'm', 4);
    end;
    function cut_address_columns( a_stack varchar2 ) return varchar2 is
    begin
      return regexp_replace( a_stack, '^(0x)?[0-9a-f]+\s+', '', 1, 0, 'mi' );
    end;
    function cut_framework_stack( a_stack varchar2 ) return varchar2 is
    begin
      return regexp_replace(
        a_stack,
        '[0-9]+\s+anonymous\s+block\s+[0-9]+\s+package\s+body\s+sys\.dbms_sql(\.execute)?\s+[0-9]+\s+[0-9_$#a-z ]+\.ut_executable.*',
        '',
        1, 1, 'mni'
        );
    end;
    function format_stack( a_stack varchar2 ) return varchar2 is
    begin
      return regexp_replace(
        a_stack,
        '([0-9]+)\s+(.* )?((anonymous block)|(([0-9_$#a-z]+\.[0-9_$#a-z]+(\.([0-9_$#a-z])+)?)))',
        'at "\3", line \1', 1, 0, 'i'
        );
    end;
  begin
    l_call_stack  := cut_header_and_expectations( a_call_stack );
    l_call_stack  := cut_address_columns( l_call_stack );
    l_call_stack := cut_framework_stack( l_call_stack );
    l_call_stack := format_stack( l_call_stack );
    l_caller_stack_line    := regexp_substr(l_call_stack,'^(.*)');
    if l_caller_stack_line like '%.%' then
      l_line_no          := to_number( regexp_substr( l_caller_stack_line, ', line (\d+)', subexpression => 1 ) );
      l_owner            := regexp_substr( l_caller_stack_line, 'at "([A-Za-z0-9$#_]+)\.(([A-Za-z0-9$#_]+)(\.([A-Za-z0-9$#_]+))?)", line (\d+)', subexpression => 1 );
      l_object_name      := regexp_substr( l_caller_stack_line, 'at "([A-Za-z0-9$#_]+)\.(([A-Za-z0-9$#_]+)(\.([A-Za-z0-9$#_]+))?)", line (\d+)', subexpression => 3 );
      l_result :=
        l_caller_stack_line || ' ' || rtrim(ut_metadata.get_source_definition_line(l_owner, l_object_name, l_line_no),chr(10))
        || replace( l_call_stack, l_caller_stack_line );
    else
      l_result := l_call_stack;
    end if;
    return rtrim(l_result,chr(10));
  end;

  procedure add_warning(a_messsage varchar2) is
  begin
    g_warnings.extend;
    g_warnings(g_warnings.last) := a_messsage;
  end;

  procedure add_depreciation_warning(a_deprecated_syntax varchar2, a_new_syntax varchar2) is
  begin
    add_warning(
      ut_utils.build_depreciation_warning( a_deprecated_syntax, a_new_syntax ) || chr(10)
      || ut_expectation_processor.who_called_expectation(dbms_utility.format_call_stack())
    );
  end;

  function get_warnings return ut_varchar2_rows is
  begin
    return g_warnings;
  end;

  function invalidation_exception_found return boolean is
  begin
    return g_package_invalidated;
  end;

  procedure set_invalidation_exception is
  begin
    g_package_invalidated := true;
  end;

  procedure reset_invalidation_exception is
  begin
    g_package_invalidated := false;
  end;

end;
/
