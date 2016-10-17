create or replace package ut_assert_processor authid current_user as

  gc_default_nulls_are_equal constant boolean := true;

  subtype boolean_not_null is boolean not null;

  function nulls_are_equal return boolean;

  procedure nulls_are_equal(a_setting boolean_not_null);

  function get_aggregate_asserts_result return integer;

  procedure clear_asserts;

  function get_asserts_results return ut_objects_list;

  procedure add_assert_result(a_assert_result ut_assert_result);

  procedure report_error(a_message in varchar2);

  procedure set_xml_nls_params;

  procedure reset_nls_params;

end;
/
