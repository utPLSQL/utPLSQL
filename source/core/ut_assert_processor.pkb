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
  begin
    g_session_params := get_session_parameters();

    --execute immediate q'[alter session set events '19119 trace name context forever, level 0x8']';

    execute immediate 'alter session set nls_date_format = '''||ut_utils.gc_date_format||'''';
    execute immediate 'alter session set nls_timestamp_format = '''||ut_utils.gc_timestamp_format||'''';
    execute immediate 'alter session set nls_timestamp_tz_format = '''||ut_utils.gc_timestamp_tz_format||'''';
  end;

  procedure reset_nls_params is
  begin
    --execute immediate q'[alter session set events '19119 trace name context off']';

    if g_session_params is not null then
      for i in 1 .. g_session_params.count loop
        execute immediate 'alter session set '||g_session_params(i).parameter||' = '''||g_session_params(i).value||'''';
      end loop;
    end if;

  end;

end;
/
