create or replace type body ut_be_within as
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

 member procedure init(self in out nocopy ut_be_within, a_distance_from_expected ut_data_value) is
  begin
    self.distance_from_expected  := a_distance_from_expected;
    self.self_type := $$plsql_unit;
  end;

  constructor function ut_be_within(self in out nocopy ut_be_within, a_distance_from_expected number) return self as result is
  begin
    init(ut_data_value_number(a_distance_from_expected));
    return;
  end;
  
  constructor function ut_be_within(self in out nocopy ut_be_within, a_distance_from_expected dsinterval_unconstrained) return self as result is
  begin
    init(ut_data_value_dsinterval(a_distance_from_expected));
    return;
  end;
  
  constructor function ut_be_within(self in out nocopy ut_be_within, a_distance_from_expected yminterval_unconstrained) return self as result is
  begin
    init(ut_data_value_yminterval(a_distance_from_expected));
    return;
  end;
  
  member procedure of_(self in ut_be_within, a_expected number) is
    l_result ut_be_within := self;
  begin 
    l_result.expected := ut_data_value_number(a_expected);
    if l_result.is_negated_flag = 1 then
      l_result.expectation.not_to(l_result );
    else
      l_result.expectation.to_(l_result );
    end if;
  end;
  
  member procedure of_(self in ut_be_within, a_expected date) is
    l_result ut_be_within := self;
  begin 
    l_result.expected := ut_data_value_date(a_expected);
    if l_result.is_negated_flag = 1 then
      l_result.expectation.not_to(l_result );
    else
      l_result.expectation.to_(l_result );
    end if;
  end;

  member function of_(self in ut_be_within, a_expected number) return ut_be_within is
    l_result ut_be_within := self;
  begin
    l_result.expected := ut_data_value_number(a_expected);
    return l_result;
  end;

  member function of_(self in ut_be_within, a_expected date)  return ut_be_within is
    l_result ut_be_within := self;
  begin
    l_result.expected := ut_data_value_date(a_expected);
    return l_result;
  end;

  overriding member function run_matcher(self in out nocopy ut_be_within, a_actual ut_data_value) return boolean is
    l_result boolean;
  begin
    if self.expected.data_type = a_actual.data_type then
      if self.expected is of (ut_data_value_number) then
        l_result := abs((treat(self.expected as ut_data_value_number).data_value - treat(a_actual as ut_data_value_number).data_value)) <= 
                    treat(self.distance_from_expected as ut_data_value_number).data_value;
      elsif self.expected is of (ut_data_value_date) and self.distance_from_expected is of ( ut_data_value_yminterval) then
        l_result := treat(a_actual as ut_data_value_date).data_value 
                    between 
                     (treat(self.expected as ut_data_value_date).data_value) - treat(self.distance_from_expected as ut_data_value_yminterval).data_value
                     and 
                     (treat(self.expected as ut_data_value_date).data_value) + treat(self.distance_from_expected as ut_data_value_yminterval).data_value;
      elsif self.expected is of (ut_data_value_date) and self.distance_from_expected is of ( ut_data_value_dsinterval) then      
        l_result := treat(a_actual as ut_data_value_date).data_value 
                    between 
                      (treat(self.expected as ut_data_value_date).data_value) - treat(self.distance_from_expected as ut_data_value_dsinterval).data_value
                      and 
                      (treat(self.expected as ut_data_value_date).data_value) + treat(self.distance_from_expected as ut_data_value_dsinterval).data_value;
      end if;
    else
      l_result := (self as ut_matcher).run_matcher(a_actual);
    end if;
    return l_result;
  end;

  overriding member function failure_message(a_actual ut_data_value) return varchar2 is
  begin                
    return (self as ut_matcher).failure_message(a_actual) || ' '||self.distance_from_expected.to_string ||' of '|| expected.to_string_report();
  end;

  overriding member function failure_message_when_negated(a_actual ut_data_value) return varchar2 is
    l_result varchar2(32767);
  begin 
    return (self as ut_matcher).failure_message_when_negated(a_actual) || ' '||self.distance_from_expected.to_string ||' of '|| expected.to_string_report();
  end;  
  
end;
/
