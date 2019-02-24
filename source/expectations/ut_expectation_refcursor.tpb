create or replace type body ut_expectation_refcursor as
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

  constructor function ut_expectation_refcursor(self in out nocopy ut_expectation_refcursor, a_actual_data ut_data_value, a_description varchar2) return self as result is
  begin
    self.actual_data := a_actual_data;
    self.description := a_description;
    return;
  end;

   member function to_equal(a_expected sys_refcursor, a_nulls_are_equal boolean := null) return ut_expectation_refcursor is
    l_result ut_expectation_refcursor := self;
  begin
    l_result.matcher := ut_equal(a_expected, a_nulls_are_equal);
    return l_result;
  end;

  member function not_to_equal(a_expected sys_refcursor, a_nulls_are_equal boolean := null) return ut_expectation_refcursor is
    l_result ut_expectation_refcursor := self;
  begin
    l_result.matcher := ut_equal(a_expected, a_nulls_are_equal).negated();
    return l_result;
  end;

  member function to_contain(a_expected sys_refcursor) return ut_expectation_refcursor is
    l_result ut_expectation_refcursor := self;
  begin
    l_result.matcher := ut_contain(a_expected);
    return l_result;
  end;

  member function not_to_contain(a_expected sys_refcursor) return ut_expectation_refcursor is
    l_result ut_expectation_refcursor := self;
  begin
    l_result.matcher := ut_contain(a_expected).negated();
    return l_result;
  end;

  overriding member function include(a_items varchar2) return ut_expectation_refcursor is
  begin
    return include( ut_varchar2_list( a_items ) );
  end;

  overriding member function include(a_items ut_varchar2_list) return ut_expectation_refcursor is
    l_result ut_expectation_refcursor;
  begin
    l_result := self;
    l_result.matcher := treat(l_result.matcher as ut_equal).include(a_items);
    return l_result;
  end;

  overriding member function exclude(a_items varchar2) return ut_expectation_refcursor is
  begin
    return exclude( ut_varchar2_list( a_items ) );
  end;

  overriding member function exclude(a_items ut_varchar2_list) return ut_expectation_refcursor is
    l_result ut_expectation_refcursor;
    begin
      l_result := self;
      l_result.matcher := treat(l_result.matcher as ut_equal).exclude(a_items);
      return l_result;
    end;

  overriding member function unordered return ut_expectation_refcursor is
    l_result ut_expectation_refcursor;
  begin
    l_result := self;
    l_result.matcher := treat(l_result.matcher as ut_equal).unordered;
    return l_result;
  end;

  overriding member function join_by(a_columns varchar2) return ut_expectation_refcursor is
  begin
    return join_by( ut_varchar2_list( a_columns ) );
  end;

  overriding member function join_by(a_columns ut_varchar2_list) return ut_expectation_refcursor is
    l_result ut_expectation_refcursor;
  begin
    l_result := self;
    l_result.matcher := treat(l_result.matcher as ut_equal).join_by(a_columns);
    return l_result;
  end;

  member function unordered_columns return ut_expectation_refcursor is
    l_result ut_expectation_refcursor;
  begin
    l_result := self;
    l_result.matcher := treat(l_result.matcher as ut_equal).unordered_columns;
    return l_result;
  end;

  member procedure unordered_columns(self in ut_expectation_refcursor) is
  begin
    self.to_( treat(matcher as ut_equal).unordered_columns );
  end;

  member function uc return ut_expectation_refcursor is
  begin
    return unordered_columns;
  end;

  member procedure uc(self in ut_expectation_refcursor) is
  begin
    unordered_columns;
  end;

end;
/
