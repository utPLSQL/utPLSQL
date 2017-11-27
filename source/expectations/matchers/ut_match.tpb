create or replace type body ut_match as
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

  constructor function ut_match(self in out nocopy ut_match, a_pattern in varchar2, a_modifiers in varchar2 default null) return self as result is
  begin
    self.self_type := $$plsql_unit;
    self.pattern   := a_pattern;
    self.modifiers := a_modifiers;
    return;
  end;

  overriding member function run_matcher(self in out nocopy ut_match, a_actual ut_data_value) return boolean is
    l_result boolean;
  begin
    if a_actual is of (ut_data_value_varchar2) then
      l_result := regexp_like(treat(a_actual as ut_data_value_varchar2).data_value, pattern, modifiers);
    elsif a_actual is of (ut_data_value_clob) then
      l_result := regexp_like(treat(a_actual as ut_data_value_clob).data_value, pattern, modifiers);
    else
      l_result := (self as ut_matcher).run_matcher(a_actual);
    end if;
    return l_result;
  end;

  overriding member function failure_message(a_actual ut_data_value) return varchar2 is
    l_result varchar2(32767);
  begin
    l_result := (self as ut_matcher).failure_message(a_actual);
    if self.modifiers is not null then
      l_result := l_result || ': '|| ut_data_value_varchar2(self.pattern).to_string_report(true, false) || ', modifiers ''' || self.modifiers ||'''';
    else
      l_result := l_result || ': '|| ut_data_value_varchar2(self.pattern).to_string_report(false, false);
    end if;
    return l_result;
  end;

  overriding member function failure_message_when_negated(a_actual ut_data_value) return varchar2 is
    l_result varchar2(32767);
  begin
    l_result := (self as ut_matcher).failure_message_when_negated(a_actual);
    if self.modifiers is not null then
      l_result := l_result || ': '|| ut_data_value_varchar2(self.pattern).to_string_report(true, false) || ', modifiers ''' || self.modifiers ||'''';
    else
      l_result := l_result || ': '|| ut_data_value_varchar2(self.pattern).to_string_report(false, false);
    end if;
    return l_result;
  end;

end;
/
