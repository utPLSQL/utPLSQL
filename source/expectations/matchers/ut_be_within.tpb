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

 member procedure init(self in out nocopy ut_be_within, a_dist ut_data_value, a_is_pct number , a_self_type varchar2 := null) is
  begin
    self.dist  := a_dist;
    self.is_pct := nvl(a_is_pct,0);
    self.self_type := nvl( a_self_type, $$plsql_unit );
  end;

  constructor function ut_be_within(self in out nocopy ut_be_within, a_dist number, a_is_pct number) return self as result is
  begin
    init(ut_data_value_number(a_dist),a_is_pct);
    return;
  end;
  
  constructor function ut_be_within(self in out nocopy ut_be_within, a_dist dsinterval_unconstrained, a_is_pct number) return self as result is
  begin
    init(ut_data_value_dsinterval(a_dist),a_is_pct); 
    return;
  end;
  
  constructor function ut_be_within(self in out nocopy ut_be_within, a_dist yminterval_unconstrained, a_is_pct number) return self as result is
  begin
    init(ut_data_value_yminterval(a_dist),a_is_pct);
    return;
  end;
  
  member procedure of_(self in ut_be_within, a_expected number) is
    l_result ut_be_within := self;
  begin 
    l_result.expected := ut_data_value_number(a_expected);
    l_result.expectation.to_(l_result );        
  end;
  
  member procedure of_(self in ut_be_within, a_expected date) is
    l_result ut_be_within := self;
  begin 
    l_result.expected := ut_data_value_date(a_expected);
    l_result.expectation.to_(l_result );    
  end;
  
  overriding member function run_matcher(self in out nocopy ut_be_within, a_actual ut_data_value) return boolean is
    l_result boolean;
  begin
    if self.expected.data_type = a_actual.data_type then
      if self.expected is of (ut_data_value_number) and self.is_pct = 0 then
        l_result := abs((treat(self.expected as ut_data_value_number).data_value - treat(a_actual as ut_data_value_number).data_value)) <= 
                    treat(self.dist as ut_data_value_number).data_value;
      elsif self.expected is of (ut_data_value_number) and self.is_pct = 1 then
        l_result := treat(self.dist as ut_data_value_number).data_value >= 
                    (
                     ((treat(self.expected as ut_data_value_number).data_value - treat(a_actual as ut_data_value_number).data_value ) * 100 ) /
                    (treat(self.expected as ut_data_value_number).data_value)) ;      
      elsif self.expected is of (ut_data_value_date) and self.dist is of ( ut_data_value_yminterval) then      
        l_result := treat(a_actual as ut_data_value_date).data_value 
                    between 
                     (treat(self.expected as ut_data_value_date).data_value) - treat(self.dist as ut_data_value_yminterval).data_value
                     and 
                     (treat(self.expected as ut_data_value_date).data_value) + treat(self.dist as ut_data_value_yminterval).data_value;
      elsif self.expected is of (ut_data_value_date) and self.dist is of ( ut_data_value_dsinterval) then      
        l_result := treat(a_actual as ut_data_value_date).data_value 
                    between 
                      (treat(self.expected as ut_data_value_date).data_value) - treat(self.dist as ut_data_value_dsinterval).data_value
                      and 
                      (treat(self.expected as ut_data_value_date).data_value) + treat(self.dist as ut_data_value_dsinterval).data_value;
      end if;
    else
      l_result := (self as ut_matcher).run_matcher(a_actual);
    end if;
    return l_result;
  end;

  overriding member function failure_message(a_actual ut_data_value) return varchar2 is
    l_distance varchar2(32767);
  begin
    l_distance := case 
                    when self.dist is of (ut_data_value_number) then
                      treat(self.dist as ut_data_value_number).to_string
                    when self.dist is of (ut_data_value_yminterval) then
                      treat(self.dist as ut_data_value_yminterval).to_string 
                    when self.dist is of (ut_data_value_dsinterval) then
                      treat(self.dist as ut_data_value_dsinterval).to_string 
                    else
                      null
                    end;
                    
    return (self as ut_matcher).failure_message(a_actual) || ' '||l_distance ||' of '|| expected.to_string_report();
  end;

  overriding member function failure_message_when_negated(a_actual ut_data_value) return varchar2 is
    l_result varchar2(32767);
  begin
    return (self as ut_matcher).failure_message_when_negated(a_actual) || ': '|| expected.to_string_report();
  end;  
  
end;
/