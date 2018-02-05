create or replace type body ut_have_count as
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

  constructor function ut_have_count(self in out nocopy ut_have_count, a_expected integer) return self as result is
  begin
    self.self_type := $$plsql_unit;
    self.expected  := a_expected;
    return;
  end;

  overriding member function run_matcher(self in out nocopy ut_have_count, a_actual ut_data_value) return boolean is
    l_result boolean;
  begin
    if a_actual is of(ut_data_value_refcursor) then
      l_result := ( self.expected = treat(a_actual as ut_data_value_refcursor).row_count );
    elsif a_actual is of(ut_data_value_collection) then
      l_result := ( self.expected = treat(a_actual as ut_data_value_collection).elements_count );
    else
      l_result := (self as ut_matcher).run_matcher(a_actual);
    end if;
    return l_result;
  end;

  overriding member function failure_message(a_actual ut_data_value) return varchar2 is
  begin
    return 'Actual: (' || a_actual.get_object_info()||') was expected to have [ count = '||ut_utils.to_string(self.expected)||' ]';
  end;

  overriding member function failure_message_when_negated(a_actual ut_data_value) return varchar2 is
  begin
    return 'Actual: ' || a_actual.get_object_info()||' was expected not to have [ count = '||ut_utils.to_string(self.expected)||' ]';
  end;

end;
/
