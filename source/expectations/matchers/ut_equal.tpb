create or replace type body ut_equal as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2017 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  member procedure init(self in out nocopy ut_equal, a_expected ut_data_value, a_nulls_are_equal boolean) is
  begin
    self.nulls_are_equal_flag := ut_utils.boolean_to_int( coalesce(a_nulls_are_equal, ut_expectation_processor.nulls_are_equal()) );
    self.self_type := $$plsql_unit;
    self.expected  := a_expected;
  end;

  member function equal_with_nulls(a_assert_result boolean, a_actual ut_data_value) return boolean is
  begin
    ut_utils.debug_log('ut_equal.equal_with_nulls :' || ut_utils.to_test_result(a_assert_result) || ':');
    return ( a_assert_result or ( self.expected.is_null() and a_actual.is_null() and ut_utils.int_to_boolean( nulls_are_equal_flag ) ) );
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected anydata, a_exclude varchar2 := null, a_include varchar2 := null, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_anydata.get_instance(a_expected, a_exclude, a_include), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected anydata, a_exclude ut_varchar2_list, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_anydata.get_instance(a_expected, a_exclude, null), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected anydata, a_exclude ut_varchar2_list := null, a_include ut_varchar2_list, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_anydata.get_instance(a_expected, a_exclude, a_include), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected blob, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_blob(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected boolean, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_boolean(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected clob, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_clob(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected date, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_date(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected number, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_number(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected sys_refcursor, a_exclude varchar2 := null, a_include varchar2 := null, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_refcursor(a_expected, a_exclude, a_include), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected sys_refcursor, a_exclude ut_varchar2_list, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_refcursor(a_expected, a_exclude), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected sys_refcursor, a_exclude ut_varchar2_list := null, a_include ut_varchar2_list, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_refcursor(a_expected, a_exclude, a_include), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_timestamp(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_timestamp_tz(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_timestamp_ltz(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected varchar2, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_varchar2(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected yminterval_unconstrained, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_yminterval(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected dsinterval_unconstrained, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_dsinterval(a_expected), a_nulls_are_equal);
    return;
  end;

  overriding member function run_matcher(self in out nocopy ut_equal, a_actual ut_data_value) return boolean is
    l_result boolean;
  begin
    if self.expected.data_type = a_actual.data_type then
      l_result := equal_with_nulls((self.expected = a_actual), a_actual);
    else
      l_result := (self as ut_matcher).run_matcher(a_actual);
    end if;
    return l_result;
  end;

  overriding member function failure_message(a_actual ut_data_value) return varchar2 is
    l_result varchar2(32767);
  begin
    return (self as ut_matcher).failure_message(a_actual) || ': '|| expected.to_string_report();
  end;

  overriding member function failure_message_when_negated(a_actual ut_data_value) return varchar2 is
    l_result varchar2(32767);
  begin
    return (self as ut_matcher).failure_message_when_negated(a_actual) || ': '|| expected.to_string_report();
  end;

end;
/
