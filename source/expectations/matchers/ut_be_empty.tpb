create or replace type body ut_be_empty as
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

  member procedure init(self in out nocopy ut_be_empty) is
  begin
    self.self_type := $$plsql_unit;
  end;

  constructor function ut_be_empty(self in out nocopy ut_be_empty) return self as result is
  begin
    init();
    return;
  end;

  overriding member function run_matcher(self in out nocopy ut_be_empty, a_actual ut_data_value) return boolean is
    l_result boolean;
  begin
    return a_actual.is_empty();
  exception 
    when value_error then
      return (self as ut_matcher).run_matcher(a_actual);
  end;

end;
/
