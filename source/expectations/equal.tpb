create or replace type body equal as

  member procedure init(self in out nocopy equal, a_expected ut_data_value, a_nulls_are_equal boolean) is
  begin
    self.nulls_are_equal := ut_utils.boolean_to_int( coalesce(a_nulls_are_equal, ut_assert_processor.nulls_are_equal()) );
    self.assert_name := lower($$plsql_unit);
    self.expected := a_expected;
  end;

  overriding member function build_assert_result( a_assert_result boolean, a_actual ut_data_value) return ut_assert_result is
  begin
    ut_utils.debug_log('equal.build_assert_result :' || ut_utils.to_test_result(a_assert_result) || ':');
    return
      (self as ut_expectation).build_assert_result(
        ( a_assert_result or ( 3 = self.expected.is_null + a_actual.is_null + self.nulls_are_equal ) )
        , a_actual
      );
  end;

  constructor function equal(self in out nocopy equal, a_expected blob, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_blob(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function equal(self in out nocopy equal, a_expected boolean, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_boolean(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function equal(self in out nocopy equal, a_expected clob, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_clob(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function equal(self in out nocopy equal, a_expected date, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_date(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function equal(self in out nocopy equal, a_expected number, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_number(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function equal(self in out nocopy equal, a_expected sys_refcursor, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_refcursor(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function equal(self in out nocopy equal, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_timestamp(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function equal(self in out nocopy equal, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_timestamp_tz(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function equal(self in out nocopy equal, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_timestamp_ltz(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function equal(self in out nocopy equal, a_expected varchar2, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_varchar2(a_expected), a_nulls_are_equal);
    return;
  end;

  overriding member function run_expectation(a_actual ut_data_value_blob) return ut_assert_result is
  begin
    return self.build_assert_result(
      dbms_lob.compare( case when self.expected is of (ut_data_value_blob) then treat(self.expected as ut_data_value_blob).value end
        , a_actual.value) = 0
      , a_actual
    );
  end;

  overriding member function run_expectation(a_actual ut_data_value_boolean) return ut_assert_result is
  begin
    return self.build_assert_result(
      case when self.expected is of (ut_data_value_boolean) then treat(self.expected as ut_data_value_boolean).value end
      = a_actual.value
      , a_actual
    );
  end;

  overriding member function run_expectation(a_actual ut_data_value_clob) return ut_assert_result is
  begin
    return self.build_assert_result(
      dbms_lob.compare(
        case when self.expected is of (ut_data_value_clob) then treat(self.expected as ut_data_value_clob).value end
       , a_actual.value) = 0
      , a_actual
    );
  end;

  overriding member function run_expectation(a_actual ut_data_value_date) return ut_assert_result is
  begin
    return self.build_assert_result(
      case when self.expected is of (ut_data_value_date) then treat(self.expected as ut_data_value_date).value end
      = a_actual.value
      , a_actual
    );
  end;

  overriding member function run_expectation(a_actual ut_data_value_number) return ut_assert_result is
  begin
    return self.build_assert_result(
      case when self.expected is of (ut_data_value_number) then treat(self.expected as ut_data_value_number).value end
      = a_actual.value
      , a_actual
    );
  end;

  overriding member function run_expectation(a_actual ut_data_value_refcursor) return ut_assert_result is
    l_expected_cursor_number number;
    l_actual_cursor_number number := a_actual.value;
    l_result  boolean := false;
  begin
    if self.expected is of (ut_data_value_refcursor) then
      l_expected_cursor_number := treat(self.expected as ut_data_value_refcursor).value;
      if l_expected_cursor_number is not null and l_actual_cursor_number is not null then
        l_result :=
           xmltype( dbms_sql.to_refcursor(l_expected_cursor_number) ).getClobVal()
           = xmltype( dbms_sql.to_refcursor(l_actual_cursor_number) ).getClobVal();
      end if;
    end if;
    return self.build_assert_result( l_result , a_actual );
  end;

  overriding member function run_expectation(a_actual ut_data_value_timestamp) return ut_assert_result is
  begin
    return self.build_assert_result(
      case when self.expected is of (ut_data_value_timestamp) then treat(self.expected as ut_data_value_timestamp).value end
      = a_actual.value
      , a_actual
    );
  end;

  overriding member function run_expectation(a_actual ut_data_value_timestamp_tz) return ut_assert_result is
  begin
    return self.build_assert_result(
      case when self.expected is of (ut_data_value_timestamp_tz) then treat(self.expected as ut_data_value_timestamp_tz).value end
      = a_actual.value
      , a_actual
    );
  end;

  overriding member function run_expectation(a_actual ut_data_value_timestamp_ltz) return ut_assert_result is
  begin
    return self.build_assert_result(
      case when self.expected is of (ut_data_value_timestamp_ltz) then treat(self.expected as ut_data_value_timestamp_ltz).value end
      = a_actual.value
      , a_actual
    );
  end;

  overriding member function run_expectation(a_actual ut_data_value_varchar2) return ut_assert_result is
  begin
    return self.build_assert_result(
      case when self.expected is of (ut_data_value_varchar2) then treat(self.expected as ut_data_value_varchar2).value end
      = a_actual.value
      , a_actual
    );
  end;

end;
/
