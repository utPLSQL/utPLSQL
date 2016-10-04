create or replace package body ut_assert_processor as

  g_asserts_called ut_assert_list := ut_assert_list();

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

  function build_message(a_message varchar2, a_expected in varchar2, a_actual in varchar2) return varchar2 is
    c_max_value_len constant integer := 1800;
  begin
    return a_message || ', expected: ' || ut_utils.to_string(a_expected)|| ', actual: ' || ut_utils.to_string(a_actual);
  end;

  procedure build_assert_result(
    a_assert_result boolean, a_assert_name varchar2, a_expected_type in varchar2, a_actual_type in varchar2,
    a_expected_value_string in varchar2, a_actual_value_string in varchar2, a_message varchar2
  ) is
  begin
    ut_utils.debug_log('ut_assert_processor.build_assert_result :' || ut_utils.to_test_result(a_assert_result) || ':' || a_message);
    add_assert_result(
      ut_assert_result(
        a_assert_name, ut_utils.to_test_result(a_assert_result),
        a_expected_type, a_actual_type, a_expected_value_string, a_actual_value_string, a_message
      )
    );
  end;

  procedure report_error(a_message in varchar2) is
  begin
    add_assert_result(ut_assert_result(ut_utils.tr_error, a_message));
  end;

end;
/
