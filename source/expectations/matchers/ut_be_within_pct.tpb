create or replace type body ut_be_within_pct as
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

  constructor function ut_be_within_pct(self in out nocopy ut_be_within_pct, a_distance_from_expected number) return self as result is
  begin
    self.init(ut_data_value_number(a_distance_from_expected));
    return;
  end;

  overriding member function run_matcher(self in out nocopy ut_be_within_pct, a_actual ut_data_value) return boolean is
    l_result boolean;
  begin
    if self.expected.data_type = a_actual.data_type then
      if self.expected is of (ut_data_value_number) then
        l_result := treat(self.distance_from_expected as ut_data_value_number).data_value >= 
                    (
                     ((treat(self.expected as ut_data_value_number).data_value - treat(a_actual as ut_data_value_number).data_value ) * 100 ) /
                    (treat(self.expected as ut_data_value_number).data_value)) ;      
      end if;
    else
      l_result := (self as ut_matcher).run_matcher(a_actual);
    end if;
    return l_result;
  end;

end;
/
