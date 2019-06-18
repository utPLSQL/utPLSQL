create or replace type body ut_expectation_json as
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

  constructor function ut_expectation_json(self in out nocopy ut_expectation_json, a_actual_data ut_data_value, a_description varchar2) return self as result is
  begin
    self.actual_data := a_actual_data;
    self.description := a_description;
    return;
  end;

  member procedure to_be_empty(self in ut_expectation_json) is
  begin
    self.to_( ut_be_empty() );
  end;

  member procedure not_to_be_empty(self in ut_expectation_json) is
  begin
    self.not_to( ut_be_empty() );
  end;

  member function to_equal(a_expected json_element_t, a_nulls_are_equal boolean := null) return ut_expectation_json is
    l_result ut_expectation_json := self;
  begin
    l_result.matcher := ut_equal(a_expected, a_nulls_are_equal);
    return l_result;
  end;

  member function not_to_equal(a_expected json_element_t, a_nulls_are_equal boolean := null) return ut_expectation_json is
    l_result ut_expectation_json := self;
  begin
    l_result.matcher := ut_equal(a_expected, a_nulls_are_equal).negated();
    return l_result;
  end;

  member procedure to_have_count(self in ut_expectation_json, a_expected integer) is
  begin
    self.to_( ut_have_count(a_expected) );
  end;

  member procedure not_to_have_count(self in ut_expectation_json, a_expected integer) is
  begin
    self.not_to( ut_have_count(a_expected) );
  end;

end;
/
