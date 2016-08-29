create or replace package body ut_assert is

  g_asserts_called ut_objects_list := ut_objects_list();

  function get_aggregate_asserts_result return integer is
    l_result integer := ut_utils.tr_success;
  begin
    ut_utils.debug_log('ut_assert.get_aggregate_asserts_result');

    for i in 1 .. g_asserts_called.count loop
      l_result := greatest(l_result, treat(g_asserts_called(i) as ut_assert_result).result);
      exit when l_result = ut_utils.tr_error;
    end loop;
    return l_result;

  end get_aggregate_asserts_result;

  procedure clear_asserts is
  begin
    ut_utils.debug_log('ut_assert.clear_asserts');
    g_asserts_called.delete;
  end;

  function get_asserts_results return ut_objects_list is
    l_asserts_results ut_objects_list;
  begin
    ut_utils.debug_log('ut_assert.get_asserts_results');
    l_asserts_results := g_asserts_called;
    clear_asserts();
    return l_asserts_results;
  end get_asserts_results;

  procedure add_assert_result(a_assert_result ut_assert_result) is
  begin
    g_asserts_called.extend;
    g_asserts_called(g_asserts_called.last) := a_assert_result;
  end;

  function build_message(a_message varchar2, a_expected in varchar2, a_actual in varchar2) return varchar2 is
    c_max_value_len constant integer := 1800;
  begin
    return
      a_message
      || ', expected: '
      || case when length(a_expected)>c_max_value_len then substr(a_expected,1,c_max_value_len-3)||'...' else a_expected end
      || ', actual: ' ||
      case when length(a_actual)>c_max_value_len then substr(a_actual,1,c_max_value_len-3)||'...' else a_actual end;
  end;

  procedure build_assert_result(a_test boolean, a_expected in varchar2, a_actual in varchar2, a_message varchar2) is
  begin
    ut_utils.debug_log('ut_assert.build_assert_result :' || ut_utils.to_test_result(a_test) || ':' || a_message);
    add_assert_result(
      ut_assert_result(
        ut_utils.to_test_result(a_test),
        build_message(a_message, a_expected, a_actual)
      )
    );
  end;

  procedure report_error(a_message in varchar2) is
  begin
    add_assert_result(ut_assert_result(ut_utils.tr_error, a_message));
  end;


  --assertions
  procedure are_equal(a_expected in number, a_actual in number) is
  begin
    are_equal('Equality test', a_expected, a_actual);
  end;

  procedure are_equal(a_msg in varchar2, a_expected in number, a_actual in number) is
  begin
    build_assert_result((a_expected = a_actual), a_expected, a_actual, a_msg);
  end;

  procedure are_equal(a_expected in anydata, a_actual in anydata) is
  begin
    are_equal('Equality test', a_expected, a_actual);
  end;

  procedure are_equal(a_msg in varchar2, a_expected in anydata, a_actual in anydata) is
    l_expected any_data;
    l_actual any_data;
  begin
     l_expected := any_data_builder.build(a_expected);
     l_actual := any_data_builder.build(a_actual);
     build_assert_result((l_expected.eq(l_actual)), l_expected.to_string(), l_actual.to_string(), a_msg);
  end;

  procedure are_equal(a_expected in sys_refcursor, a_actual in sys_refcursor) is
  begin
    are_equal('Equality test', a_expected, a_actual);
  end;

  procedure are_equal(a_msg in varchar2, a_expected in sys_refcursor, a_actual in sys_refcursor) is
    l_expected any_data;
    l_actual any_data;
  begin
     l_expected := any_data_builder.build(a_expected);
     l_actual := any_data_builder.build(a_actual);
     build_assert_result((l_expected.eq(l_actual)), l_expected.to_string(), l_actual.to_string(), a_msg);
  end;

end ut_assert;
/
