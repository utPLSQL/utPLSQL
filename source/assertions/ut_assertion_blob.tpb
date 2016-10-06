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

  overriding member procedure to_equal(self in ut_assertion_blob, a_expected blob, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion_blob.to_equal(self in ut_assertion, a_expected blob)');
    self.build_assert_result(
      (   (a_expected is null and self.actual is null and coalesce(a_nulls_are_equal, ut_assert_processor.nulls_are_equal()))
       or (dbms_lob.compare( a_expected, self.actual ) = 0)), 'to equal', ut_utils.to_string(a_expected)
    );
  end;

end;
/
