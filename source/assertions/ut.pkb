create or replace package body ut is

--  function expect(a_actual in boolean) return ut_assertion_bolean is
--  begin
--    return ut_assertion_boolean(a_actual);
--  end;

  function expect(a_actual in number, a_message varchar2 := null) return ut_assertion_number is
  begin
    return ut_assertion_number(a_actual);
  end;

  function expect(a_actual in varchar2, a_message varchar2 := null) return ut_assertion_varchar2 is
  begin
    return ut_assertion_varchar2(a_actual);
  end;

  function expect(a_actual in clob, a_message varchar2 := null) return ut_assertion_clob is
  begin
    return ut_assertion_clob(a_actual);
  end;

  function expect(a_actual in blob, a_message varchar2 := null) return ut_assertion_blob is
  begin
    return ut_assertion_blob(a_actual);
  end;


--  function expect(a_actual in date, a_message varchar2 := null) return ut_assertion_date is
--  begin
--    return ut_assertion_date(a_actual);
--  end;
--
--  function expect(a_actual in timestamp_tz_unconstrained, a_message varchar2 := null) return ut_assertion_timestamp is
--  begin
--    return ut_assertion_timestamp(a_actual);
--  end;
--
--  function expect(a_actual in anydata, a_message varchar2 := null) return ut_assertion_anydata;
--
--  function expect(a_actual in sys_refcursor, a_message varchar2 := null) return ut_assertion_cursor;

end ut;
/
