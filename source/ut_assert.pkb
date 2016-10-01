create or replace package body ut_assert is

  g_asserts_called ut_assert_list := ut_assert_list();

  function get_aggregate_asserts_result return integer is
    l_result integer := ut_utils.tr_success;
  begin
    ut_utils.debug_log('ut_assert.get_aggregate_asserts_result');
  
    for i in 1 .. g_asserts_called.count loop
      l_result := greatest(l_result, g_asserts_called(i).result);
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
    l_asserts_results ut_objects_list := ut_objects_list();
  begin
    ut_utils.debug_log('ut_assert.get_asserts_results');
    if g_asserts_called is not null and g_asserts_called.count > 0 then
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
    ut_utils.debug_log('ut_assert.build_assert_result :' || ut_utils.to_test_result(a_assert_result) || ':' || a_message);
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


  --assertions
  procedure are_equal(a_expected in number, a_actual in number) is
  begin
    are_equal(null, a_expected, a_actual);
  end;

  procedure are_equal(a_msg in varchar2, a_expected in number, a_actual in number) is
  begin
    build_assert_result((a_expected = a_actual), 'are_equal', 'number', 'number', ut_utils.to_string(a_expected), ut_utils.to_string(a_actual), ut_utils.to_string(a_msg));
  end;

  procedure are_equal(a_expected in varchar2, a_actual in varchar2) is
  begin
    are_equal(null, a_expected, a_actual);
  end;

  procedure are_equal(a_msg in varchar2, a_expected in varchar2, a_actual in varchar2) is
  begin
    build_assert_result((a_expected = a_actual), 'are_equal', 'varchar2', 'varchar2', ut_utils.to_string(a_expected), ut_utils.to_string(a_actual), ut_utils.to_string(a_msg));
  end;

  procedure are_equal(a_expected in date, a_actual in date) is
  begin
    are_equal(null, a_expected, a_actual);
  end;

  procedure are_equal(a_msg in varchar2, a_expected in date, a_actual in date) is
  begin
    build_assert_result((a_expected = a_actual), 'are_equal', 'date', 'date', ut_utils.to_string(a_expected), ut_utils.to_string(a_actual), ut_utils.to_string(a_msg));
  end;

  procedure are_equal(a_expected in timestamp_unconstrained, a_actual in timestamp_unconstrained) is
  begin
    are_equal(null, a_expected, a_actual);
  end;

  procedure are_equal(a_msg in varchar2, a_expected in timestamp_unconstrained, a_actual in timestamp_unconstrained) is
  begin
    build_assert_result((a_expected = a_actual), 'are_equal', 'timestamp', 'timestamp', ut_utils.to_string(a_expected), ut_utils.to_string(a_actual), ut_utils.to_string(a_msg));
  end;

  procedure are_equal(a_expected in anydata, a_actual in anydata) is
  begin
    are_equal(null, a_expected, a_actual);
  end;

  procedure are_equal(a_msg in varchar2, a_expected in anydata, a_actual in anydata) is
    l_expected any_data;
    l_actual   any_data;
  begin
    l_expected := any_data_builder.build(a_expected);
    l_actual   := any_data_builder.build(a_actual);
    build_assert_result( l_expected.eq(l_actual), 'are_equal', l_expected.type_name, l_actual.type_name, ut_utils.to_string(l_expected.to_string()), ut_utils.to_string(l_actual.to_string()), ut_utils.to_string(a_msg));
  end;

  procedure are_equal(a_expected in sys_refcursor, a_actual in sys_refcursor) is
  begin
    are_equal(null, a_expected, a_actual);
  end;

  procedure are_equal(a_msg in varchar2, a_expected in sys_refcursor, a_actual in sys_refcursor) is
    l_expected any_data;
    l_actual   any_data;
  begin
    l_expected := any_data_builder.build(a_expected);
    l_actual   := any_data_builder.build(a_actual);
    build_assert_result( l_expected.eq(l_actual), 'are_equal', l_expected.type_name, l_actual.type_name, ut_utils.to_string(l_expected.to_string()), ut_utils.to_string(l_actual.to_string()), ut_utils.to_string(a_msg));
  end;

  procedure this(a_condition in boolean) is
  begin
    this('Simple assert', a_condition);
  end;

  procedure this(a_msg in varchar2, a_condition in boolean) is
  begin
    build_assert_result(a_condition, 'this', 'boolean', 'boolean', ut_utils.to_string(true), ut_utils.to_string(a_condition), ut_utils.to_string(a_msg));
  end;
	
  -- Strings assertions
  procedure str_like(a_msg in varchar2, a_checking_string in varchar2, a_mask in varchar, a_escape_char in varchar2) is
    l_condition boolean;
  begin
    if a_escape_char is not null then
      l_condition := a_checking_string like a_mask escape a_escape_char;
    else
      l_condition := a_checking_string like a_mask;
    end if;
    build_assert_result(l_condition, 'str_like', 'varchar2', 'varchar2', ut_utils.to_string('like ' || a_mask), ut_utils.to_string(l_condition), a_msg);
  end;
  procedure str_like(a_msg in varchar2, a_checking_string in varchar2, a_mask in varchar) is
  begin
    str_like(a_msg, a_checking_string, a_mask, null);
  end;
  procedure str_like(a_checking_string in varchar2, a_mask in varchar2) is
  begin
    str_like(a_msg => null, a_checking_string => a_checking_string, a_mask => a_mask);
  end;
	
  procedure regexp_like(a_msg in varchar2, a_srcstr in varchar2, a_pattern in varchar2, a_modifier in varchar2 default null) is
    l_condition boolean := sys.standard.regexp_like(a_srcstr, a_pattern, a_pattern);
  begin
    build_assert_result(l_condition, 'regexp_like', 'varchar2', 'varchar2', ut_utils.to_string('pattern ' || a_pattern), ut_utils.to_string(l_condition), a_msg);
  end;
	 
  procedure regexp_like(a_srcstr in varchar2, a_pattern in varchar2, a_modifier in varchar2 default null) is
  begin
    regexp_like(null, a_srcstr, a_pattern, a_modifier);
  end;

  procedure is_null(a_actual in number) is
  begin
    is_null(null, a_actual);
  end;

  procedure is_null(a_msg in varchar2, a_actual in number) is
  begin
    build_assert_result((a_actual is null), 'is_null', 'number', 'number', 'NULL', ut_utils.to_string(a_actual), ut_utils.to_string(a_msg));
  end;

  procedure is_null(a_actual in varchar2) is
  begin
    is_null(null, a_actual);
  end;

  procedure is_null(a_msg in varchar2, a_actual in varchar2) is
  begin
    build_assert_result((a_actual is null), 'is_null', 'varchar2', 'varchar2', 'NULL', ut_utils.to_string(a_actual), ut_utils.to_string(a_msg));
  end;


  procedure is_null(a_actual in date) is
  begin
    is_null(null, a_actual);
  end;


  procedure is_null(a_msg in varchar2, a_actual in date) is
  begin
    build_assert_result((a_actual is null), 'is_null', 'date', 'date', 'NULL', ut_utils.to_string(a_actual), ut_utils.to_string(a_msg));
  end;


  procedure is_null(a_actual in timestamp_unconstrained) is
  begin
    is_null(null, a_actual);
  end;


  procedure is_null(a_msg in varchar2, a_actual in timestamp_unconstrained) is
  begin
    build_assert_result((a_actual is null), 'is_null', 'timestamp', 'timestamp', 'NULL', ut_utils.to_string(a_actual), ut_utils.to_string(a_msg));
  end;


  procedure is_null(a_actual in anydata) is
  begin
    is_null(null, a_actual);
  end;


  procedure is_null(a_msg in varchar2, a_actual in anydata) is
    l_actual any_data;
  begin
    l_actual := any_data_builder.build(a_actual);
    build_assert_result( l_actual.is_null(), 'is_null', l_actual.type_name, l_actual.type_name, 'NULL', ut_utils.to_string(l_actual.to_string()), ut_utils.to_string(a_msg));
  end;

  procedure is_not_null(a_actual in number) is
  begin
    is_not_null(null, a_actual);
  end;

  procedure is_not_null(a_msg in varchar2, a_actual in number) is
  begin
    build_assert_result((a_actual is not null), 'is_not_null', 'number', 'number', 'NOT NULL', ut_utils.to_string(a_actual), ut_utils.to_string(a_msg));
  end;

  procedure is_not_null(a_actual in varchar2) is
  begin
    is_not_null(null, a_actual);
  end;

  procedure is_not_null(a_msg in varchar2, a_actual in varchar2) is
  begin
    build_assert_result((a_actual is not null), 'is_not_null', 'varchar2', 'varchar2', 'NOT NULL', ut_utils.to_string(a_actual), ut_utils.to_string(a_msg));
  end;

  procedure is_not_null(a_actual in date) is
  begin
    is_not_null(null, a_actual);
  end;

  procedure is_not_null(a_msg in varchar2, a_actual in date) is
  begin
    build_assert_result((a_actual is not null), 'is_not_null', 'date', 'date', 'NOT NULL', ut_utils.to_string(a_actual), ut_utils.to_string(a_msg));
  end;

  procedure is_not_null(a_actual in timestamp_unconstrained) is
  begin
    is_not_null(null, a_actual);
  end;

  procedure is_not_null(a_msg in varchar2, a_actual in timestamp_unconstrained) is
  begin
    build_assert_result((a_actual is not null), 'is_not_null', 'timestamp', 'timestamp', 'NOT NULL', ut_utils.to_string(a_actual), ut_utils.to_string(a_msg));
  end;

  procedure is_not_null(a_actual in anydata) is
  begin
    is_not_null(null, a_actual);
  end;

  procedure is_not_null(a_msg in varchar2, a_actual in anydata) is
    l_actual any_data;
  begin
    l_actual := any_data_builder.build(a_actual);
    build_assert_result( not l_actual.is_null(), 'is_not_null', l_actual.type_name, l_actual.type_name, 'NOT NULL', ut_utils.to_string(l_actual.to_string()), ut_utils.to_string(a_msg));
  end;


end ut_assert;
/
