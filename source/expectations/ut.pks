create or replace package ut authid current_user as

  function expect(a_actual in anydata, a_message varchar2 := null) return ut_expectation_anydata;

  function expect(a_actual in blob, a_message varchar2 := null) return ut_expectation_blob;

  function expect(a_actual in boolean, a_message varchar2 := null) return ut_expectation_boolean;

  function expect(a_actual in clob, a_message varchar2 := null) return ut_expectation_clob;

  function expect(a_actual in date, a_message varchar2 := null) return ut_expectation_date;

  function expect(a_actual in number, a_message varchar2 := null) return ut_expectation_number;

  function expect(a_actual in sys_refcursor, a_message varchar2 := null) return ut_expectation_refcursor;

  function expect(a_actual in timestamp_unconstrained, a_message varchar2 := null) return ut_expectation_timestamp;

  function expect(a_actual in timestamp_ltz_unconstrained, a_message varchar2 := null) return ut_expectation_timestamp_ltz;

  function expect(a_actual in timestamp_tz_unconstrained, a_message varchar2 := null) return ut_expectation_timestamp_tz;

  function expect(a_actual in varchar2, a_message varchar2 := null) return ut_expectation_varchar2;

  function expect(a_actual in yminterval_unconstrained, a_message varchar2 := null) return ut_expectation_yminterval;

  function expect(a_actual in dsinterval_unconstrained, a_message varchar2 := null) return ut_expectation_dsinterval;

end ut;
/
