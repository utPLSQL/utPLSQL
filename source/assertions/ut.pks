create or replace package ut authid current_user as

  function expect(a_actual in anydata, a_message varchar2 := null) return ut_assertion_anydata;

  function expect(a_actual in blob, a_message varchar2 := null) return ut_assertion_blob;

  function expect(a_actual in boolean, a_message varchar2 := null) return ut_assertion_boolean;

  function expect(a_actual in clob, a_message varchar2 := null) return ut_assertion_clob;

  function expect(a_actual in date, a_message varchar2 := null) return ut_assertion_date;

  function expect(a_actual in number, a_message varchar2 := null) return ut_assertion_number;

  function expect(a_actual in sys_refcursor, a_message varchar2 := null) return ut_assertion_refcursor;

  function expect(a_actual in timestamp_unconstrained, a_message varchar2 := null) return ut_assertion_timestamp;

  function expect(a_actual in timestamp_ltz_unconstrained, a_message varchar2 := null) return ut_assertion_timestamp_ltz;

  function expect(a_actual in timestamp_tz_unconstrained, a_message varchar2 := null) return ut_assertion_timestamp_tz;

  function expect(a_actual in varchar2, a_message varchar2 := null) return ut_assertion_varchar2;

end ut;
/
