create or replace type body equal as

  member procedure init(self in out nocopy equal, a_expected ut_data_value, a_nulls_are_equal boolean) is
  begin
    self.nulls_are_equal_flag := ut_utils.boolean_to_int( coalesce(a_nulls_are_equal, ut_assert_processor.nulls_are_equal()) );
    self.name := lower($$plsql_unit);
    self.expected := a_expected;
  end;

  member function equal_with_nulls(a_assert_result boolean, a_actual ut_data_value) return boolean is
  begin
    ut_utils.debug_log('equal.equal_with_nulls :' || ut_utils.to_test_result(a_assert_result) || ':');
    return ( a_assert_result or ( self.expected.is_null() and a_actual.is_null() and ut_utils.int_to_boolean( nulls_are_equal_flag ) ) );
  end;

  constructor function equal(self in out nocopy equal, a_expected anydata, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_anydata(a_expected), a_nulls_are_equal);
    return;
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

  overriding member function run_expectation(a_actual ut_data_value) return boolean is
    l_result boolean;
  begin
    if self.expected is of (ut_data_value_anydata) and a_actual is of (ut_data_value_anydata) then
      declare
        l_expected ut_data_value_anydata := treat(self.expected as ut_data_value_anydata);
        l_actual   ut_data_value_anydata := treat(a_actual as ut_data_value_anydata);
      begin
        l_result := equal_with_nulls((xmltype(l_expected.value).getclobval() = xmltype(l_actual.value).getclobval()), a_actual);
      end;
    elsif self.expected is of (ut_data_value_blob) and a_actual is of (ut_data_value_blob) then
      declare
        l_expected ut_data_value_blob := treat(self.expected as ut_data_value_blob);
        l_actual   ut_data_value_blob := treat(a_actual as ut_data_value_blob);
      begin
        l_result := equal_with_nulls((dbms_lob.compare( l_expected.value, l_actual.value) = 0), a_actual);
      end;
    elsif self.expected is of (ut_data_value_boolean) and a_actual is of (ut_data_value_boolean) then
      declare
        l_expected ut_data_value_boolean := treat(self.expected as ut_data_value_boolean);
        l_actual   ut_data_value_boolean := treat(a_actual as ut_data_value_boolean);
      begin
        l_result := equal_with_nulls((l_expected.value = l_actual.value), a_actual);
      end;
    elsif self.expected is of (ut_data_value_clob) and a_actual is of (ut_data_value_clob) then
      declare
        l_expected ut_data_value_clob := treat(self.expected as ut_data_value_clob);
        l_actual   ut_data_value_clob := treat(a_actual as ut_data_value_clob);
      begin
        l_result := equal_with_nulls((dbms_lob.compare( l_expected.value, l_actual.value) = 0), a_actual);
      end;
    elsif self.expected is of (ut_data_value_date) and a_actual is of (ut_data_value_date) then
      declare
        l_expected ut_data_value_date := treat(self.expected as ut_data_value_date);
        l_actual   ut_data_value_date := treat(a_actual as ut_data_value_date);
      begin
        l_result := equal_with_nulls((l_expected.value = l_actual.value), a_actual);
      end;
    elsif self.expected is of (ut_data_value_number) and a_actual is of (ut_data_value_number) then
      declare
        l_expected ut_data_value_number := treat(self.expected as ut_data_value_number);
        l_actual   ut_data_value_number := treat(a_actual as ut_data_value_number);
      begin
        l_result := equal_with_nulls((l_expected.value = l_actual.value), a_actual);
      end;
    elsif self.expected is of (ut_data_value_refcursor) and a_actual is of (ut_data_value_refcursor) then
      declare
        l_expected ut_data_value_refcursor := treat(self.expected as ut_data_value_refcursor);
        l_actual   ut_data_value_refcursor := treat(a_actual as ut_data_value_refcursor);
      begin
        l_result :=
          equal_with_nulls(
            (  xmltype( dbms_sql.to_refcursor(l_expected.value) ).getClobVal
              = xmltype( dbms_sql.to_refcursor(l_actual.value) ).getClobVal)
            , a_actual
          );
      end;
    elsif self.expected is of (ut_data_value_timestamp) and a_actual is of (ut_data_value_timestamp) then
      declare
        l_expected ut_data_value_timestamp := treat(self.expected as ut_data_value_timestamp);
        l_actual   ut_data_value_timestamp := treat(a_actual as ut_data_value_timestamp);
      begin
        l_result := equal_with_nulls((l_expected.value = l_actual.value), a_actual);
      end;
    elsif self.expected is of (ut_data_value_timestamp_ltz) and a_actual is of (ut_data_value_timestamp_ltz) then
      declare
        l_expected ut_data_value_timestamp_ltz := treat(self.expected as ut_data_value_timestamp_ltz);
        l_actual   ut_data_value_timestamp_ltz := treat(a_actual as ut_data_value_timestamp_ltz);
      begin
        l_result := equal_with_nulls((l_expected.value = l_actual.value), a_actual);
      end;
    elsif self.expected is of (ut_data_value_timestamp_tz) and a_actual is of (ut_data_value_timestamp_tz) then
      declare
        l_expected ut_data_value_timestamp_tz := treat(self.expected as ut_data_value_timestamp_tz);
        l_actual   ut_data_value_timestamp_tz := treat(a_actual as ut_data_value_timestamp_tz);
      begin
        l_result := equal_with_nulls((l_expected.value = l_actual.value), a_actual);
      end;
    elsif self.expected is of (ut_data_value_varchar2) and a_actual is of (ut_data_value_varchar2) then
      declare
        l_expected ut_data_value_varchar2 := treat(self.expected as ut_data_value_varchar2);
        l_actual   ut_data_value_varchar2 := treat(a_actual as ut_data_value_varchar2);
      begin
        l_result := equal_with_nulls((l_expected.value = l_actual.value), a_actual);
      end;
    else
      l_result := (self as ut_expectation).run_expectation(a_actual);
    end if;
    return l_result;
  end;

end;
/
