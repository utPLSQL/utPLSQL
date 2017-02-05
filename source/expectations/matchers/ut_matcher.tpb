create or replace type body ut_matcher as
  /*
  utPLSQL - Version X.X.X.X
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

  member function run_matcher(self in out nocopy ut_matcher, a_actual ut_data_value) return boolean is
  begin
    ut_utils.debug_log('Failure - ut_matcher.run_matcher'||'(a_actual '||a_actual.data_type||')');
    self.error_message := 'The matcher '''||self.name||''' cannot be used';
    if self.expected is not null then
      self.error_message := self.error_message ||' for comparison of data type ('||self.expected.data_type||')';
    end if;
    self.error_message := self.error_message ||' with data type ('||a_actual.data_type||').';
    return null;
  end;

end;
/
