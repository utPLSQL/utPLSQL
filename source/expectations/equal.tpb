create or replace type body equal as

  member procedure init(self in out nocopy equal, a_expected ut_data_value, a_nulls_are_equal boolean) is
  begin
    self.nulls_are_equal := ut_utils.boolean_to_int( coalesce(a_nulls_are_equal, ut_assert_processor.nulls_are_equal()) );
    self.assert_name := lower($$plsql_unit);
    self.expected := a_expected;
  end;

  overriding member function build_assert_result( self in equal, a_assert_result boolean, a_actual ut_data_value) return ut_assert_result is
    l_nulls_are_equal boolean;
  begin
    ut_utils.debug_log('equal.build_assert_result :' || ut_utils.to_test_result(a_assert_result) || ':');
    l_nulls_are_equal := (self.expected.is_null + a_actual.is_null + self.nulls_are_equal = 3); --all 3 are true
    return
      ut_assert_result(
        self.assert_name, ut_utils.to_test_result(a_assert_result or l_nulls_are_equal),
        self.expected.type, a_actual.type,
        self.expected.value_string, a_actual.value_string, null
      );
  end;

  constructor function equal(self in out nocopy equal, a_expected varchar2, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_varchar2('varchar2', ut_utils.boolean_to_int(a_expected is null), ut_utils.to_string(a_expected), a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function equal(self in out nocopy equal, a_expected number, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_number('number', ut_utils.boolean_to_int(a_expected is null), ut_utils.to_string(a_expected), a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function equal(self in out nocopy equal, a_expected clob, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_clob('clob', ut_utils.boolean_to_int(a_expected is null), ut_utils.to_string(a_expected), a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function equal(self in out nocopy equal, a_expected blob, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_blob('blob', ut_utils.boolean_to_int(a_expected is null), ut_utils.to_string(a_expected), a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function equal(self in out nocopy equal, a_expected date, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_date('date', ut_utils.boolean_to_int(a_expected is null), ut_utils.to_string(a_expected), a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function equal(self in out nocopy equal, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_date('timestamp', ut_utils.boolean_to_int(a_expected is null), ut_utils.to_string(a_expected), a_expected), a_nulls_are_equal);
    return;
  end;

  overriding member function run_expectation(self in equal, a_actual ut_data_value_varchar2) return ut_assert_result is
    l_expected varchar2(32767 char);
  begin
    l_expected :=
      case
        when self.expected is of (ut_data_value_varchar2) then treat(self.expected as ut_data_value_varchar2).value
      end;
    return
      self.build_assert_result((l_expected = a_actual.value), a_actual);
  end;

  overriding member function run_expectation(self in equal, a_actual ut_data_value_number) return ut_assert_result is
    l_expected number;
  begin
    l_expected :=
      case
        when self.expected is of (ut_data_value_number) then treat(self.expected as ut_data_value_number).value
      end;
    return
      self.build_assert_result((l_expected = a_actual.value), a_actual);
  end;

  overriding member function run_expectation(self in equal, a_actual ut_data_value_clob) return ut_assert_result is
    l_expected clob;
  begin
    l_expected :=
      case
        when self.expected is of (ut_data_value_clob) then treat(self.expected as ut_data_value_clob).value
      end;
    return
      self.build_assert_result((l_expected = a_actual.value), a_actual);
  end;

  overriding member function run_expectation(self in equal, a_actual ut_data_value_blob) return ut_assert_result is
    l_expected blob;
  begin
    l_expected :=
      case
        when self.expected is of (ut_data_value_blob) then treat(self.expected as ut_data_value_blob).value
      end;
    return
      self.build_assert_result((dbms_lob.compare( l_expected, a_actual.value ) = 0), a_actual);
  end;

  overriding member function run_expectation(self in equal, a_actual ut_data_value_date) return ut_assert_result is
    l_expected date;
  begin
    l_expected :=
      case
        when self.expected is of (ut_data_value_date) then treat(self.expected as ut_data_value_date).value
      end;
    return
      self.build_assert_result((l_expected = a_actual.value), a_actual );
  end;

  overriding member function run_expectation(self in equal, a_actual ut_data_value_timestamp) return ut_assert_result is
    l_expected timestamp_tz_unconstrained;
  begin
    l_expected :=
      case
        when self.expected is of (ut_data_value_timestamp) then treat(self.expected as ut_data_value_timestamp).value
      end;
    return
      self.build_assert_result((l_expected = a_actual.value), a_actual );
  end;

end;
/
