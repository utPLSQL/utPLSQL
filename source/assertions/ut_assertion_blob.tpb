create or replace type body ut_assertion_blob as

  constructor function ut_assertion_blob(self in out nocopy ut_assertion_blob, a_actual blob, a_message varchar2 default null) return self as result is
  begin
    self.data_type := 'blob';
    self.message := a_message;
    self.actual := a_actual;
    self.actual_value_string := ut_utils.to_string(a_actual);
    self.is_null := ut_utils.boolean_to_int( (a_actual is null) );
    return;
  end;

  overriding member procedure to_be_equal(self in ut_assertion_blob, a_expected blob) is
  begin
    ut_utils.debug_log('ut_assertion_blob.to_be_equal(self in ut_assertion, a_expected blob)');
    self.build_assert_result( (dbms_lob.compare( a_expected, self.actual ) = 0), 'to be equal', ut_utils.to_string(a_expected));
  end;

end;
/
