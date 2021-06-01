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

  constructor function ut_be_within(self in out nocopy ut_be_within, a_distance_from_expected number) return self as result is
  begin
    self.init(ut_data_value_number(a_distance_from_expected), $$plsql_unit);
    return;
  end;
  
  constructor function ut_be_within(self in out nocopy ut_be_within, a_distance_from_expected dsinterval_unconstrained) return self as result is
  begin
    self.init(ut_data_value_dsinterval(a_distance_from_expected), $$plsql_unit);
    return;
  end;

  constructor function ut_be_within(self in out nocopy ut_be_within, a_distance_from_expected yminterval_unconstrained) return self as result is
  begin
    self.init(ut_data_value_yminterval(a_distance_from_expected), $$plsql_unit);
    return;
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

  member function of_(self in ut_be_within, a_expected date)  return ut_be_within is
    l_result ut_be_within := self;
  begin
    l_result.expected := ut_data_value_date(a_expected);
    return l_result;
  end;
  
  member procedure of_(self in ut_be_within, a_expected timestamp) is
    l_result ut_be_within := self;
  begin 
    l_result.expected := ut_data_value_timestamp(a_expected);
    if l_result.is_negated_flag = 1 then
      l_result.expectation.not_to(l_result );
    else
      l_result.expectation.to_(l_result );
    end if;
  end;

  member function of_(self in ut_be_within, a_expected timestamp)  return ut_be_within is
    l_result ut_be_within := self;
  begin
    l_result.expected := ut_data_value_timestamp(a_expected);
    return l_result;
  end;  

  member procedure of_(self in ut_be_within, a_expected timestamp_tz_unconstrained) is
    l_result ut_be_within := self;
  begin 
    l_result.expected := ut_data_value_timestamp_tz(a_expected);
    if l_result.is_negated_flag = 1 then
      l_result.expectation.not_to(l_result );
    else
      l_result.expectation.to_(l_result );
    end if;
  end;

  member function of_(self in ut_be_within, a_expected  timestamp_tz_unconstrained)  return ut_be_within is
    l_result ut_be_within := self;
  begin
    l_result.expected := ut_data_value_timestamp_tz(a_expected);
    return l_result;
  end;    
  
  member procedure of_(self in ut_be_within, a_expected  timestamp_ltz_unconstrained) is
    l_result ut_be_within := self;
  begin 
    l_result.expected := ut_data_value_timestamp_ltz(a_expected);
    if l_result.is_negated_flag = 1 then
      l_result.expectation.not_to(l_result );
    else
      l_result.expectation.to_(l_result );
    end if;
  end;

  member function of_(self in ut_be_within, a_expected timestamp_ltz_unconstrained)  return ut_be_within is
    l_result ut_be_within := self;
  begin
    l_result.expected := ut_data_value_timestamp_ltz(a_expected);
    return l_result;
  end;    
  
  overriding member function run_matcher(self in out nocopy ut_be_within, a_actual ut_data_value) return boolean is
    l_result     boolean;
   begin
    if self.expected.data_type = a_actual.data_type then
      if self.expected is of (ut_data_value_date, ut_data_value_number, ut_data_value_timestamp, ut_data_value_timestamp_tz, ut_data_value_timestamp_ltz) then
        l_result := ut_be_within_helper.values_within_abs_distance(self.expected, a_actual, self.distance_from_expected) ;
      else
        l_result := (self as ut_matcher).run_matcher(a_actual);
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
  begin
    return (self as ut_matcher).failure_message_when_negated(a_actual) || ' '||self.distance_from_expected.to_string ||' of '|| expected.to_string_report();
  end;

end;
/
