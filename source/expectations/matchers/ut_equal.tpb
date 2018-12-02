create or replace type body ut_equal as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2018 utPLSQL Project

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
    self.include_list := ut_varchar2_list();
    self.exclude_list := ut_varchar2_list();
    self.join_columns := ut_varchar2_list();
  end;
 
  member function equal_with_nulls(a_assert_result boolean, a_actual ut_data_value) return boolean is
  begin
    ut_utils.debug_log('ut_equal.equal_with_nulls :' || ut_utils.to_test_result(a_assert_result) || ':');
    return ( a_assert_result or ( self.expected.is_null() and a_actual.is_null() and ut_utils.int_to_boolean( nulls_are_equal_flag ) ) );
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected anydata, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_anydata.get_instance(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected anydata, a_exclude varchar2, a_nulls_are_equal boolean := null) return self as result is
    l_deprecated integer;
  begin
    ut_expectation_processor.add_depreciation_warning(
      'equal( a_expected anydata, a_exclude varchar2 )',
      'equal( a_expected anydata ).exclude( a_exclude varchar2 )'
    );
    init(ut_data_value_anydata.get_instance(a_expected), a_nulls_are_equal);
    exclude_list := ut_varchar2_list(a_exclude);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected anydata, a_exclude ut_varchar2_list, a_nulls_are_equal boolean := null) return self as result is
  begin
    ut_expectation_processor.add_depreciation_warning(
      'equal( a_expected anydata, a_exclude ut_varchar2_list )',
      'equal( a_expected anydata ).exclude( a_exclude ut_varchar2_list )'
    );
    init(ut_data_value_anydata.get_instance(a_expected), a_nulls_are_equal);
    exclude_list := coalesce(a_exclude, ut_varchar2_list());
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

  constructor function ut_equal(self in out nocopy ut_equal, a_expected sys_refcursor, a_nulls_are_equal boolean := null) return self as result is
  begin
    init(ut_data_value_refcursor(a_expected), a_nulls_are_equal);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected sys_refcursor, a_exclude varchar2, a_nulls_are_equal boolean := null) return self as result is
  begin
    ut_expectation_processor.add_depreciation_warning(
      'equal( a_expected sys_refcursor, a_exclude varchar2 )',
      'equal( a_expected sys_refcursor ).exclude( a_exclude varchar2 )'
    );
    init(ut_data_value_refcursor(a_expected), a_nulls_are_equal);
    exclude_list := ut_varchar2_list(a_exclude);
    return;
  end;

  constructor function ut_equal(self in out nocopy ut_equal, a_expected sys_refcursor, a_exclude ut_varchar2_list, a_nulls_are_equal boolean := null) return self as result is
  begin
    ut_expectation_processor.add_depreciation_warning(
      'equal( a_expected sys_refcursor, a_exclude ut_varchar2_list )',
      'equal( a_expected sys_refcursor ).exclude( a_exclude ut_varchar2_list )'
    );
    init(ut_data_value_refcursor(a_expected), a_nulls_are_equal);
    exclude_list := coalesce(a_exclude, ut_varchar2_list());
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

  member function include(a_items varchar2) return ut_equal is
    l_result ut_equal := self;
  begin
    l_result.include_list := l_result.include_list multiset union coalesce(ut_utils.string_to_table(REPLACE(a_items,'|',','),','),ut_varchar2_list());
    return l_result;
  end;

  member function include(a_items ut_varchar2_list) return ut_equal is
    l_result ut_equal := self;
    l_items  ut_varchar2_list := ut_varchar2_list();
  begin
    for i in 1..a_items.count loop
      l_items := l_items multiset union all coalesce(ut_utils.string_to_table(REPLACE(a_items(i),'|',','),','),ut_varchar2_list());
    end loop;
    l_result.include_list := l_result.include_list multiset union all coalesce(l_items,ut_varchar2_list());
    return l_result;
  end;

  member function exclude(a_items varchar2) return ut_equal is
    l_result ut_equal := self;
  begin
    l_result.exclude_list := l_result.exclude_list multiset union all coalesce(ut_utils.string_to_table(REPLACE(a_items,'|',','),','),ut_varchar2_list());
    return l_result;
  end;

  member function exclude(a_items ut_varchar2_list) return ut_equal is
    l_result ut_equal := self;
    l_items  ut_varchar2_list := ut_varchar2_list();
  begin
    for i in 1..a_items.count loop
     l_items := l_items multiset union all coalesce(ut_utils.string_to_table(REPLACE(a_items(i),'|',','),','),ut_varchar2_list());
    end loop;
    
    l_result.exclude_list := l_result.exclude_list multiset union all coalesce(l_items,ut_varchar2_list());
    return l_result;
  end;

  member function unordered return ut_equal is
    l_result ut_equal := self;
  begin
    l_result.is_unordered := ut_utils.boolean_to_int(true);
    return l_result;
  end;

  member function join_by(a_columns varchar2) return ut_equal is
    l_result ut_equal := self;
  begin
    l_result.is_unordered := ut_utils.boolean_to_int(true);
    l_result.join_columns := l_result.join_columns multiset union all coalesce(ut_utils.string_to_table(REPLACE(a_columns,'|',','),','),ut_varchar2_list());
    
    select regexp_replace(column_value,'^((/ROW/)|^(//)|^(/\*/))?(.*)','\5') col_names
    bulk collect into l_result.join_on_list
    from table(l_result.join_columns);
    return l_result;
  end;

  member function join_by(a_columns ut_varchar2_list) return ut_equal is
    l_result ut_equal := self;
    l_items  ut_varchar2_list := ut_varchar2_list();
  begin
    l_result.is_unordered := ut_utils.boolean_to_int(true);
    for i in 1..a_columns.count loop
      --TODO :  idoiot proof solution for both include and exclude
      l_items := l_items multiset union all coalesce(ut_utils.string_to_table(REPLACE(a_columns(i),'|',','),','),ut_varchar2_list());
    end loop;
    l_result.join_columns := l_result.join_columns multiset union all coalesce(l_items,ut_varchar2_list());
    
    select regexp_replace(column_value,'^((/ROW/)|^(//)|^(/\*/))?(.*)','\5') col_names
    bulk collect into l_result.join_on_list
    from table(l_result.join_columns);
    
    return l_result;
  end;

  member function get_include_xpath return varchar2 is
  begin
    return ut_utils.to_xpath( coalesce(include_list, ut_varchar2_list()) );
  end;

  member function get_exclude_xpath return varchar2 is
  begin
    return ut_utils.to_xpath( coalesce(exclude_list, ut_varchar2_list()) );
  end;

  member function get_unordered return boolean is
  begin
   return ut_utils.int_to_boolean(nvl(is_unordered,0));
  end;
  
  member function get_join_by_xpath return varchar2 is
  begin
    return ut_utils.to_xpath( coalesce(join_columns, ut_varchar2_list()) );
  end;
  
  member function get_join_by_list return ut_varchar2_list is
  begin
    return ( coalesce(join_columns, ut_varchar2_list()) );
  end;
  
  overriding member function run_matcher(self in out nocopy ut_equal, a_actual ut_data_value) return boolean is
    l_result boolean;
    l_actual ut_data_value;
  begin
    if self.expected.data_type = a_actual.data_type then
      if self.expected is of (ut_data_value_anydata) then
        l_result := 0 = treat(self.expected as ut_data_value_anydata).compare_implementation(a_actual, get_exclude_xpath(), get_include_xpath());
      elsif self.expected is of (ut_data_value_refcursor) then
        l_actual := treat(a_actual as ut_data_value_refcursor).filter_cursor(exclude_list, include_list);
        l_result := 0 = treat(self.expected as ut_data_value_refcursor).filter_cursor(exclude_list, include_list).compare_implementation(l_actual, get_unordered(), false, false, get_join_by_list() );
      else
        l_result := equal_with_nulls((self.expected = a_actual), a_actual);
      end if;
      l_result := equal_with_nulls( l_result, a_actual );
    else
      l_result := (self as ut_matcher).run_matcher(a_actual);
    end if;
    return l_result;
  end;

  overriding member function failure_message(a_actual ut_data_value) return varchar2 is
    l_result varchar2(32767);
    l_actual ut_data_value;
  begin
    if self.expected.data_type = a_actual.data_type and self.expected.is_diffable then
      if self.expected is of (ut_data_value_refcursor) then
        l_actual := treat(a_actual as ut_data_value_refcursor).filter_cursor(exclude_list, include_list);
        l_result :=
          'Actual: '||a_actual.get_object_info()||' '||self.description()||': '||self.expected.get_object_info()
          || chr(10) || 'Diff:' || treat(expected as ut_data_value_refcursor).filter_cursor(exclude_list, include_list).filter_cursor(exclude_list, include_list).diff(l_actual, get_unordered(),get_join_by_list());      
      else
        l_result :=
          'Actual: '||a_actual.get_object_info()||' '||self.description()||': '||self.expected.get_object_info()
          || chr(10) || 'Diff:' || expected.diff(a_actual, get_exclude_xpath(), get_include_xpath(), get_join_by_xpath(), get_unordered());
      end if;
    else
      l_result := (self as ut_matcher).failure_message(a_actual) || ': '|| self.expected.to_string_report();
    end if;
    return l_result;
  end;

  overriding member function failure_message_when_negated(a_actual ut_data_value) return varchar2 is
    l_result varchar2(32767);
  begin
    return (self as ut_matcher).failure_message_when_negated(a_actual) || ': '|| expected.to_string_report();
  end;

end;
/
