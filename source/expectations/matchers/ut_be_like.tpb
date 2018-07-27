create or replace type body ut_be_like as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2018 utPLSQL Project

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

  constructor function ut_be_like(self in out nocopy ut_be_like, a_mask in varchar2, a_escape_char in varchar2 := null) return self as result is
  begin
    self.self_type   := $$plsql_unit;
    self.mask        := a_mask;
    self.escape_char := a_escape_char;
    return;
  end ut_be_like;

  overriding member function run_matcher(self in out nocopy ut_be_like, a_actual ut_data_value) return boolean is
    l_value  clob;
    l_result boolean;
  begin
    if a_actual is of (ut_data_value_varchar2, ut_data_value_clob) then

      if a_actual is of (ut_data_value_varchar2) then
        l_value := treat(a_actual as ut_data_value_varchar2).data_value;
      else
        l_value := treat(a_actual as ut_data_value_clob).data_value;
      end if;

      if escape_char is not null then
        l_result := l_value like mask escape escape_char;
      else
        l_result := l_value like mask;
      end if;
    else
      l_result := (self as ut_matcher).run_matcher(a_actual);
    end if;
    return l_result;
  end run_matcher;

  overriding member function failure_message(a_actual ut_data_value) return varchar2 is
    l_result varchar2(32767);
  begin
    l_result := (self as ut_matcher).failure_message(a_actual);
    if self.escape_char is not null then
      l_result := l_result || ': '|| ut_data_value_varchar2(self.mask).to_string_report(true, false) || ', escape ''' || self.escape_char ||'''';
    else
      l_result := l_result || ': '|| ut_data_value_varchar2(self.mask).to_string_report(false, false);
    end if;
    return l_result;
  end;

  overriding member function failure_message_when_negated(a_actual ut_data_value) return varchar2 is
    l_result varchar2(32767);
  begin
    l_result := (self as ut_matcher).failure_message_when_negated(a_actual);
    if self.escape_char is not null then
      l_result := l_result || ': '|| ut_data_value_varchar2(self.mask).to_string_report(true, false) || ', escape ''' || self.escape_char ||'''';
    else
      l_result := l_result || ': '|| ut_data_value_varchar2(self.mask).to_string_report(false, false);
    end if;
    return l_result;
  end;

end;
/
