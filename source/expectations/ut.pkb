create or replace package body ut is

  function expect(a_actual in anydata, a_message varchar2 := null) return ut_expectation_anydata is
  begin
    return ut_expectation_anydata(ut_data_value_anydata(a_actual), a_message);
  end;

  function expect(a_actual in blob, a_message varchar2 := null) return ut_expectation_blob is
  begin
    return ut_expectation_blob(ut_data_value_blob(a_actual), a_message);
  end;

  function expect(a_actual in boolean, a_message varchar2 := null) return ut_expectation_boolean is
  begin
    return ut_expectation_boolean(ut_data_value_boolean(a_actual), a_message);
  end;

  function expect(a_actual in clob, a_message varchar2 := null) return ut_expectation_clob is
  begin
    return ut_expectation_clob(ut_data_value_clob(a_actual), a_message);
  end;

  function expect(a_actual in date, a_message varchar2 := null) return ut_expectation_date is
  begin
    return ut_expectation_date(ut_data_value_date(a_actual), a_message);
  end;

  function expect(a_actual in number, a_message varchar2 := null) return ut_expectation_number is
  begin
    return ut_expectation_number(ut_data_value_number(a_actual), a_message);
  end;

  function expect(a_actual in timestamp_unconstrained, a_message varchar2 := null) return ut_expectation_timestamp is
  begin
    return ut_expectation_timestamp(ut_data_value_timestamp(a_actual), a_message);
  end;

  function expect(a_actual in timestamp_ltz_unconstrained, a_message varchar2 := null) return ut_expectation_timestamp_ltz is
  begin
    return ut_expectation_timestamp_ltz(ut_data_value_timestamp_ltz(a_actual), a_message);
  end;

  function expect(a_actual in timestamp_tz_unconstrained, a_message varchar2 := null) return ut_expectation_timestamp_tz is
  begin
    return ut_expectation_timestamp_tz(ut_data_value_timestamp_tz(a_actual), a_message);
  end;

  function expect(a_actual in varchar2, a_message varchar2 := null) return ut_expectation_varchar2 is
  begin
    return ut_expectation_varchar2(ut_data_value_varchar2(a_actual), a_message);
  end;

  function expect(a_actual in sys_refcursor, a_message varchar2 := null) return ut_expectation_refcursor is
  begin
    return ut_expectation_refcursor(ut_data_value_refcursor(a_actual), a_message);
  end;

end ut;
/
