create or replace package body ut_assert is

  --assertions
  procedure are_equal(a_expected in number, a_actual in number) is
  begin
    are_equal(null, a_expected, a_actual);
  end;

  procedure are_equal(a_msg in varchar2, a_expected in number, a_actual in number) is
  begin
    ut.expect(a_actual,a_msg).to_equal(a_expected);
  end;

  procedure are_equal(a_expected in varchar2, a_actual in varchar2) is
  begin
    are_equal(null, a_expected, a_actual);
  end;

  procedure are_equal(a_msg in varchar2, a_expected in varchar2, a_actual in varchar2) is
  begin
    ut.expect(a_actual,a_msg).to_equal(a_expected);
  end;

  procedure are_equal(a_expected in date, a_actual in date) is
  begin
    are_equal(null, a_expected, a_actual);
  end;

  procedure are_equal(a_msg in varchar2, a_expected in date, a_actual in date) is
  begin
    ut.expect(a_actual,a_msg).to_equal(a_expected);
  end;

  procedure are_equal(a_expected in timestamp_unconstrained, a_actual in timestamp_unconstrained) is
  begin
    are_equal(null, a_expected, a_actual);
  end;

  procedure are_equal(a_msg in varchar2, a_expected in timestamp_unconstrained, a_actual in timestamp_unconstrained) is
  begin
    ut.expect(a_actual,a_msg).to_equal(a_expected);
  end;

  procedure are_equal(a_expected in anydata, a_actual in anydata) is
  begin
    are_equal(null, a_expected, a_actual);
  end;

  procedure are_equal(a_msg in varchar2, a_expected in anydata, a_actual in anydata) is
  begin
    ut.expect(a_actual,a_msg).to_equal(a_expected);
  end;

  procedure are_equal(a_expected in sys_refcursor, a_actual in sys_refcursor) is
  begin
    are_equal(null, a_expected, a_actual);
  end;

  procedure are_equal(a_msg in varchar2, a_expected in sys_refcursor, a_actual in sys_refcursor) is
  begin
    ut.expect(a_actual,a_msg).to_equal(a_expected);
  end;

  procedure this(a_condition in boolean) is
  begin
    this('Simple assert', a_condition);
  end;

  procedure this(a_msg in varchar2, a_condition in boolean) is
  begin
    ut.expect(a_condition,a_msg).to_be_true();
  end;
	
  -- Strings assertions
  procedure is_like(a_msg in varchar2, a_checking_string in varchar2, a_mask in varchar, a_escape_char in varchar2) is
  begin
    ut.expect(a_checking_string, a_msg).to_be_like(a_mask, a_escape_char);
  end;

  procedure is_like(a_msg in varchar2, a_checking_string in varchar2, a_mask in varchar) is
  begin
    is_like(a_msg, a_checking_string, a_mask, null);
  end;

  procedure is_like(a_checking_string in varchar2, a_mask in varchar2) is
  begin
    is_like(a_msg => null, a_checking_string => a_checking_string, a_mask => a_mask);
  end;
	
  procedure is_matching(a_msg in varchar2, a_checking_string in varchar2, a_pattern in varchar2, a_modifier in varchar2 default null) is
    l_condition boolean := sys.standard.regexp_like(a_checking_string, a_pattern, a_modifier);
  begin
    ut.expect(a_checking_string, a_msg).to_match(a_pattern, a_modifier);
  end;
	 
  procedure is_matching(a_checking_string in varchar2, a_pattern in varchar2, a_modifier in varchar2 default null) is
  begin
    is_matching(null, a_checking_string, a_pattern, a_modifier);
  end;

  procedure is_null(a_actual in number) is
  begin
    is_null(null, a_actual);
  end;

  procedure is_null(a_msg in varchar2, a_actual in number) is
  begin
    ut.expect(a_actual,a_msg).to_be_null();
  end;

  procedure is_null(a_actual in varchar2) is
  begin
    is_null(null, a_actual);
  end;

  procedure is_null(a_msg in varchar2, a_actual in varchar2) is
  begin
    ut.expect(a_actual,a_msg).to_be_null();
  end;


  procedure is_null(a_actual in date) is
  begin
    is_null(null, a_actual);
  end;


  procedure is_null(a_msg in varchar2, a_actual in date) is
  begin
    ut.expect(a_actual,a_msg).to_be_null();
  end;


  procedure is_null(a_actual in timestamp_unconstrained) is
  begin
    is_null(null, a_actual);
  end;


  procedure is_null(a_msg in varchar2, a_actual in timestamp_unconstrained) is
  begin
    ut.expect(a_actual,a_msg).to_be_null();
  end;


  procedure is_null(a_actual in anydata) is
  begin
    is_null(null, a_actual);
  end;


  procedure is_null(a_msg in varchar2, a_actual in anydata) is
  begin
    ut.expect(a_actual,a_msg).to_be_null();
  end;

  procedure is_not_null(a_actual in number) is
  begin
    is_not_null(null, a_actual);
  end;

  procedure is_not_null(a_msg in varchar2, a_actual in number) is
  begin
    ut.expect(a_actual,a_msg).to_be_not_null();
  end;

  procedure is_not_null(a_actual in varchar2) is
  begin
    is_not_null(null, a_actual);
  end;

  procedure is_not_null(a_msg in varchar2, a_actual in varchar2) is
  begin
    ut.expect(a_actual,a_msg).to_be_not_null();
  end;

  procedure is_not_null(a_actual in date) is
  begin
    is_not_null(null, a_actual);
  end;

  procedure is_not_null(a_msg in varchar2, a_actual in date) is
  begin
    ut.expect(a_actual,a_msg).to_be_not_null();
  end;

  procedure is_not_null(a_actual in timestamp_unconstrained) is
  begin
    is_not_null(null, a_actual);
  end;

  procedure is_not_null(a_msg in varchar2, a_actual in timestamp_unconstrained) is
  begin
    ut.expect(a_actual,a_msg).to_be_not_null();
  end;

  procedure is_not_null(a_actual in anydata) is
  begin
    is_not_null(null, a_actual);
  end;

  procedure is_not_null(a_msg in varchar2, a_actual in anydata) is
  begin
    ut.expect(a_actual,a_msg).to_be_not_null();
  end;


end ut_assert;
/
