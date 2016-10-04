create or replace package body ut is

--  function expect(a_actual in boolean) return ut_assertion_bolean is
--  begin
--    return ut_assertion_boolean(a_actual);
--  end;

  function expect(a_actual in number) return ut_assertion_number is
  begin
    return ut_assertion_number(a_actual);
  end;

  function expect(a_actual in varchar2) return ut_assertion_varchar is
  begin
    return ut_assertion_varchar(a_actual);
  end;

--  function expect(a_actual in raw) return ut_assertion_raw is
--  begin
--    return ut_assertion_raw(a_actual);
--  end;

--  function expect(a_actual in clob) return ut_assertion_clob is
--  begin
--    return ut_assertion_clob(a_actual);
--  end;
--
--  function expect(a_actual in blob) return ut_assertion_blob is
--  begin
--    return ut_assertion_blob(a_actual);
--  end;
--
--
--  function expect(a_actual in date) return ut_assertion_date is
--  begin
--    return ut_assertion_date(a_actual);
--  end;
--
--  function expect(a_actual in timestamp_tz_unconstrained) return ut_assertion_timestamp is
--  begin
--    return ut_assertion_timestamp(a_actual);
--  end;
--
--  function expect(a_actual in anydata) return ut_assertion_anydata;
--
--  function expect(a_actual in sys_refcursor) return ut_assertion_cursor;

end ut;
/
