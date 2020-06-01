create or replace type body ut_expectation_compound as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

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

  constructor function ut_expectation_compound(self in out nocopy ut_expectation_compound, a_actual_data ut_data_value, a_description varchar2) return self as result is
  begin
    self.actual_data := a_actual_data;
    self.description := a_description;
    return;
  end;

  member procedure to_have_count(self in ut_expectation_compound, a_expected integer) is
  begin
    self.to_( ut_have_count(a_expected) );
  end;

  member procedure not_to_have_count(self in ut_expectation_compound, a_expected integer) is
  begin
    self.not_to( ut_have_count(a_expected) );
  end;


  member function to_equal(a_expected anydata, a_nulls_are_equal boolean := null) return ut_expectation_compound is
    l_result ut_expectation_compound := self;
  begin
    l_result.matcher := ut_equal(a_expected, a_nulls_are_equal);
    return l_result;
  end;

  member function not_to_equal(a_expected anydata, a_nulls_are_equal boolean := null) return ut_expectation_compound is
    l_result ut_expectation_compound := self;
  begin
    l_result.matcher := ut_equal(a_expected, a_nulls_are_equal).negated();
    return l_result;
  end;

   member function to_equal(a_expected sys_refcursor, a_nulls_are_equal boolean := null) return ut_equal is
    l_result ut_expectation_compound := self;
  begin
    l_result.matcher := ut_equal(a_expected, a_nulls_are_equal);
    l_result.matcher.expectation := l_result;
    return treat(l_result.matcher as ut_equal);
  end;

  member function not_to_equal(a_expected sys_refcursor, a_nulls_are_equal boolean := null) return ut_expectation_compound is
    l_result ut_expectation_compound := self;
  begin
    l_result.matcher := ut_equal(a_expected, a_nulls_are_equal).negated();
    return l_result;
  end;

  member function to_contain(a_expected sys_refcursor) return ut_expectation_compound is
    l_result ut_expectation_compound := self;
  begin
    l_result.matcher := ut_contain(a_expected);
    return l_result;
  end;

  member function not_to_contain(a_expected sys_refcursor) return ut_expectation_compound is
    l_result ut_expectation_compound := self;
  begin
    l_result.matcher := ut_contain(a_expected).negated();
    return l_result;
  end;

  member function to_contain(a_expected anydata) return ut_expectation_compound is
    l_result ut_expectation_compound := self;
  begin
    l_result.matcher := ut_contain(a_expected);
    return l_result;
  end;

  member function not_to_contain(a_expected anydata) return ut_expectation_compound is
    l_result ut_expectation_compound := self;
  begin
    l_result.matcher := ut_contain(a_expected).negated();
    return l_result;
  end;

  member function include(a_items varchar2) return ut_expectation_compound is
  begin
    return include( ut_varchar2_list( a_items ) );
  end;

  member function include(a_items ut_varchar2_list) return ut_expectation_compound is
    l_result ut_expectation_compound := self;
  begin
    l_result.matcher := treat(l_result.matcher as ut_equal).include(a_items);
    return l_result;
  end;

  member procedure include(self in ut_expectation_compound, a_items varchar2) is
  begin
    include( ut_varchar2_list( a_items ) );
  end;

  member procedure include(self in ut_expectation_compound, a_items ut_varchar2_list) is
  begin
    self.to_( treat(matcher as ut_equal).include(a_items) );
  end;

  member function exclude(a_items varchar2) return ut_expectation_compound is
  begin
    return exclude( ut_varchar2_list( a_items ) );
  end;

  member function exclude(a_items ut_varchar2_list) return ut_expectation_compound is
    l_result ut_expectation_compound := self;
  begin
    l_result.matcher := treat(l_result.matcher as ut_equal).exclude(a_items);
    return l_result;
  end;

  member procedure exclude(self in ut_expectation_compound, a_items varchar2) is
  begin
    exclude( ut_varchar2_list( a_items ) );
  end;

  member procedure exclude(self in ut_expectation_compound, a_items ut_varchar2_list) is
  begin
    self.to_( treat(matcher as ut_equal).exclude(a_items) );
  end;
    
  member function unordered return ut_expectation_compound is
    l_result ut_expectation_compound := self;
  begin
    l_result.matcher := treat(l_result.matcher as ut_equal).unordered();
    return l_result;
  end;

  member procedure unordered(self in ut_expectation_compound) is
  begin
    self.to_( treat(matcher as ut_equal).unordered() );
  end;

  member function join_by(a_columns varchar2) return ut_expectation_compound is
  begin
    return join_by( ut_varchar2_list( a_columns ) );
  end;

  member function join_by(a_columns ut_varchar2_list) return ut_expectation_compound is
    l_result ut_expectation_compound;
  begin
    l_result := self;
    l_result.matcher := treat(l_result.matcher as ut_equal).join_by(a_columns);
    return l_result;
  end;

  member procedure join_by(self in ut_expectation_compound, a_columns varchar2) is
  begin
    join_by( ut_varchar2_list( a_columns ) );
  end;

  member procedure join_by(self in ut_expectation_compound, a_columns ut_varchar2_list) is
  begin
    self.to_( treat(matcher as ut_equal).join_by(a_columns) );
  end;

  member function unordered_columns return ut_expectation_compound is
    l_result ut_expectation_compound;
  begin
    l_result := self;
    l_result.matcher := treat(l_result.matcher as ut_equal).unordered_columns;
    return l_result;
  end;

  member procedure unordered_columns(self in ut_expectation_compound) is
  begin
    self.to_( treat(matcher as ut_equal).unordered_columns );
  end;

  member function uc return ut_expectation_compound is
  begin
    return unordered_columns;
  end;

  member procedure uc(self in ut_expectation_compound) is
  begin
    unordered_columns;
  end;

end;
/
