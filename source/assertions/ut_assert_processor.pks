create or replace package ut_assert_processor authid current_user as

  gc_default_nulls_are_equal constant boolean := true;

  subtype boolean_not_null is boolean not null;

  function nulls_are_equal return boolean;

  procedure nulls_are_equal(a_setting boolean_not_null);

  function get_aggregate_asserts_result return integer;

  procedure clear_asserts;

  function get_asserts_results return ut_objects_list;

  procedure add_assert_result(a_assert_result ut_assert_result);

  function build_message(a_message varchar2, a_expected in varchar2, a_actual in varchar2) return varchar2;

  procedure build_assert_result(
    a_assert_result boolean, a_assert_name varchar2, a_expected_type in varchar2, a_actual_type in varchar2,
    a_expected_value_string in varchar2, a_actual_value_string in varchar2, a_message varchar2
  );

  procedure report_error(a_message in varchar2);

end;
/
