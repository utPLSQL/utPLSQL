create or replace type body ut_matcher_bi_operand as
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

  overriding member function error_message(a_actual ut_data_value) return varchar2 is
    l_result varchar2(32767);
  begin
    if ut_utils.int_to_boolean(self.is_errored) then
      l_result := 'Actual ('||a_actual.data_type||') cannot be compared to Expected ('||expected.data_type||') using matcher '''||self.name()||'''.';
    end if;
    return l_result;
  end;

end;
/
