create or replace package ut_assert authid current_user as

  function get_aggregate_asserts_result return integer;
  procedure clear_asserts;
  procedure report_error(a_message in varchar2);
  function get_asserts_results return ut_objects_list;
	
  /* Just need something to play with for now */
  procedure are_equal(a_expected in number, a_actual in number);
  procedure are_equal(a_msg in varchar2, a_expected in number, a_actual in number);

  procedure are_equal(a_expected in varchar2, a_actual in varchar2);
  procedure are_equal(a_msg in varchar2, a_expected in varchar2, a_actual in varchar2);

  procedure are_equal(a_expected in date, a_actual in date);
  procedure are_equal(a_msg in varchar2, a_expected in date, a_actual in date);

  procedure are_equal(a_expected in timestamp_unconstrained, a_actual in timestamp_unconstrained);
  procedure are_equal(a_msg in varchar2, a_expected in timestamp_unconstrained, a_actual in timestamp_unconstrained);

  procedure are_equal(a_expected in anydata, a_actual in anydata);
  procedure are_equal(a_msg in varchar2, a_expected in anydata, a_actual in anydata);

  procedure are_equal(a_expected in sys_refcursor, a_actual in sys_refcursor);
  procedure are_equal(a_msg in varchar2, a_expected in sys_refcursor, a_actual in sys_refcursor);
  
  procedure this(a_condition in boolean);
  procedure this(a_msg in varchar2, a_condition in boolean);

  procedure is_null(a_actual in number);
  procedure is_null(a_msg in varchar2, a_actual in number);

  procedure is_null(a_actual in varchar2);
  procedure is_null(a_msg in varchar2, a_actual in varchar2);

  procedure is_null(a_actual in date);
  procedure is_null(a_msg in varchar2, a_actual in date);

  procedure is_null(a_actual in timestamp_unconstrained);
  procedure is_null(a_msg in varchar2, a_actual in timestamp_unconstrained);

  procedure is_null(a_actual in anydata);
  procedure is_null(a_msg in varchar2, a_actual in anydata);

  procedure is_not_null(a_actual in number);
  procedure is_not_null(a_msg in varchar2, a_actual in number);

  procedure is_not_null(a_actual in varchar2);
  procedure is_not_null(a_msg in varchar2, a_actual in varchar2);

  procedure is_not_null(a_actual in date);
  procedure is_not_null(a_msg in varchar2, a_actual in date);

  procedure is_not_null(a_actual in timestamp_unconstrained);
  procedure is_not_null(a_msg in varchar2, a_actual in timestamp_unconstrained);

  procedure is_not_null(a_actual in anydata);
  procedure is_not_null(a_msg in varchar2, a_actual in anydata);

end ut_assert;
/
