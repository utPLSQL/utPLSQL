create or replace package ut authid current_user as

--  function expect(a_message varchar2 := null, a_actual in boolean) return ut_assertion_bolean;


  function expect(a_actual in number, a_message varchar2 := null) return ut_assertion_number;

  function expect(a_actual in varchar2, a_message varchar2 := null) return ut_assertion_varchar;

  function expect(a_actual in clob, a_message varchar2 := null) return ut_assertion_clob;

  function expect(a_actual in blob, a_message varchar2 := null) return ut_assertion_blob;


--  function expect(a_message varchar2 := null, a_actual in date) return ut_assertion_date;
--
--  function expect(a_message varchar2 := null, a_actual in timestamp_tz_unconstrained) return ut_assertion_timestamp;
--
--
--  function expect(a_message varchar2 := null, a_actual in anydata) return ut_assertion_anydata;
--
--  function expect(a_message varchar2 := null, a_actual in sys_refcursor) return ut_assertion_cursor;


end ut;
/
