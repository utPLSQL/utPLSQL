create or replace package body ut_assert_processor as

  type tt_nls_params is table of nls_session_parameters%rowtype;

  g_session_params tt_nls_params;

  g_asserts_called ut_assert_list := ut_assert_list();

  g_nulls_are_equal boolean_not_null := gc_default_nulls_are_equal;

  function nulls_are_equal return boolean is
  begin
    return g_nulls_are_equal;
  end;

  procedure nulls_are_equal(a_setting boolean_not_null) is
  begin
    g_nulls_are_equal := a_setting;
  end;

  function get_aggregate_asserts_result return integer is
    l_result integer := ut_utils.tr_success;
  begin
    ut_utils.debug_log('ut_assert_processor.get_aggregate_asserts_result');

    for i in 1 .. g_asserts_called.count loop
      l_result := greatest(l_result, g_asserts_called(i).result);
      exit when l_result = ut_utils.tr_error;
    end loop;
    return l_result;

  end get_aggregate_asserts_result;

  procedure clear_asserts is
  begin
    ut_utils.debug_log('ut_assert_processor.clear_asserts');
    g_asserts_called.delete;
  end;

  function get_asserts_results return ut_objects_list is
    l_asserts_results ut_objects_list := ut_objects_list();
  begin
    ut_utils.debug_log('ut_assert_processor.get_asserts_results');
    if g_asserts_called is not null and g_asserts_called.count > 0 then
      ut_utils.debug_log('ut_assert_processor.get_asserts_results: .count='||g_asserts_called.count);
      l_asserts_results.extend(g_asserts_called.count);
      for i in 1 .. g_asserts_called.count loop
        l_asserts_results(i) := g_asserts_called(i);
      end loop;
      clear_asserts();
    end if;
    return l_asserts_results;
  end get_asserts_results;

  procedure add_assert_result(a_assert_result ut_assert_result) is
  begin
    ut_utils.debug_log('ut_assert_processor.add_assert_result');
    g_asserts_called.extend;
    g_asserts_called(g_asserts_called.last) := a_assert_result;
  end;

  procedure report_error(a_message in varchar2) is
  begin
    add_assert_result(ut_assert_result(ut_utils.tr_error, a_message));
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

  function get_source_definition_line(a_owner varchar2, a_object_name varchar2, a_line_no integer) return varchar2 is
    l_line varchar2(4000);
  begin
    execute immediate
      q'[select text from dba_source
          where owner = :a_owner and name = :a_object_name and line = :a_line_no
             -- skip the declarations, consider only definitions
            and type not in ('PACKAGE', 'TYPE') ]'
      into l_line using a_owner, a_object_name, a_line_no;
    return '"'||ltrim(rtrim( lower( l_line ), chr(10) ))||'"';
  exception
    when no_data_found then
      return null;
  end;

  function who_called_expectation return varchar2 is
    l_call_stack                 varchar2(32767) := dbms_utility.format_call_stack();
    l_caller_stack_line          varchar2(4000);
    l_caller_type_and_name       varchar2(4000);
    l_line_no                    integer;
    l_owner                      varchar2(100);
    l_object_name                varchar2(100);
    l_last_space_pos             integer;
    l_object_delimiter_pos       integer;
    c_expectation_search_pattern constant varchar2(50) := '(.*\.UT_EXPECTATION[A-Z0-9#_$]*\s)+(.*)\s';
  begin
    l_caller_stack_line    := regexp_substr( l_call_stack, c_expectation_search_pattern, 1, 1, 'm', 2);
    l_line_no              := to_number( trim( substr( l_caller_stack_line, 11, 10 ) ) );
    l_caller_type_and_name    := substr( l_caller_stack_line, 23 );
    l_last_space_pos       := instr( l_caller_type_and_name, ' ', -1 );
    l_object_delimiter_pos := instr( l_caller_type_and_name, '.' );
    if l_object_delimiter_pos > 0 then
      l_owner := substr( l_caller_type_and_name, l_last_space_pos + 1, l_object_delimiter_pos - l_last_space_pos - 1 );
      l_object_name  := substr( l_caller_type_and_name, l_object_delimiter_pos + 1 );
    end if;
    return
      case when l_owner is not null and l_object_name is not null and l_line_no is not null then
        'at "'||l_owner||'.'||l_object_name||'", line '||l_line_no||' '||get_source_definition_line(l_owner, l_object_name, l_line_no)
      end;
  end;
end;
/
