create or replace package ut_assert authid current_user as

  function get_assert_list_final_result(a_assert_list in ut_objects_list) return integer;
  function current_assert_test_result return integer;
  procedure clear_asserts;
  procedure report_error(a_message in varchar2);
  procedure process_asserts(a_newtable out ut_objects_list);
	
  /* Just need something to play with for now */
  procedure are_equal(a_expected in number, a_actual in number);
  procedure are_equal(a_msg in varchar2, a_expected in number, a_actual in number);

  procedure are_equal(a_expected in anydata, a_actual in anydata);
  procedure are_equal(a_msg in varchar2, a_expected in anydata, a_actual in anydata);

  procedure are_equal(a_expected in sys_refcursor, a_actual in sys_refcursor);
  procedure are_equal(a_msg in varchar2, a_expected in sys_refcursor, a_actual in sys_refcursor);

end ut_assert;
/
