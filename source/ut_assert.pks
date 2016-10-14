create or replace package ut_assert authid current_user as

	-- General assertion
  procedure this(a_msg in varchar2, a_condition in boolean);
  procedure this(a_condition in boolean);

  -- Equality assertions
  procedure are_equal(a_msg in varchar2, a_expected in number, a_actual in number);
  procedure are_equal(a_expected in number, a_actual in number);

  procedure are_equal(a_msg in varchar2, a_expected in varchar2, a_actual in varchar2);
  procedure are_equal(a_expected in varchar2, a_actual in varchar2);

  procedure are_equal(a_msg in varchar2, a_expected in date, a_actual in date);
  procedure are_equal(a_expected in date, a_actual in date);

  procedure are_equal(a_msg in varchar2, a_expected in timestamp_unconstrained, a_actual in timestamp_unconstrained);
  procedure are_equal(a_expected in timestamp_unconstrained, a_actual in timestamp_unconstrained);

  procedure are_equal(a_msg in varchar2, a_expected in anydata, a_actual in anydata);
  procedure are_equal(a_expected in anydata, a_actual in anydata);

  procedure are_equal(a_msg in varchar2, a_expected in sys_refcursor, a_actual in sys_refcursor);
  procedure are_equal(a_expected in sys_refcursor, a_actual in sys_refcursor);
  
  -- Pattern matching assertions
	procedure is_like(a_msg in varchar2, a_checking_string in varchar2, a_mask in varchar, a_escape_char in varchar2);
	procedure is_like(a_msg in varchar2, a_checking_string in varchar2, a_mask in varchar);
	procedure is_like(a_checking_string in varchar2, a_mask in varchar2);
	
	procedure is_matching(a_msg in varchar2, a_checking_string in varchar2,a_pattern in varchar2, a_modifier in varchar2 default null);
	procedure is_matching(a_checking_string in varchar2,a_pattern in varchar2, a_modifier in varchar2 default null);

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
