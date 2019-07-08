create or replace type body ut_matcher as
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

  member function run_matcher(self in out nocopy ut_matcher, a_actual ut_data_value) return boolean is
  begin
    ut_utils.debug_log('Failure - ut_matcher.run_matcher'||'(a_actual '||a_actual.data_type||')');
    self.is_errored := ut_utils.boolean_to_int(true);
--     self.error_message := 'The matcher '''||name()||''' cannot be used';
--     if self.expected is not null then
--       self.error_message := self.error_message ||' for comparison of data type ('||self.expected.data_type||')';
--     end if;
--     self.error_message := self.error_message ||' with data type ('||a_actual.data_type||').';
    return null;
  end;

  member function run_matcher_negated(self in out nocopy ut_matcher, a_actual ut_data_value) return boolean is
  begin
    return not run_matcher(a_actual);
  end;

  member function name return varchar2 is
  begin
    return replace(ltrim(lower(self.self_type),'ut_'),'_',' ');
  end;

  member function description return varchar2 is
  begin
    return ' was expected to '||name();
  end;

  member function description_when_negated return varchar2 is
  begin
    return ' was expected not to '||name();
  end;

  member function error_message(a_actual ut_data_value) return varchar2 is
    l_result varchar2(32767);
  begin
    if ut_utils.int_to_boolean(self.is_errored) then
      l_result := 'The matcher '''||name()||''' cannot be used with data type ('||a_actual.data_type||').';
    end if;
    return l_result;
  end;

  member function failure_message(a_actual ut_data_value) return varchar2 is
  begin
    return  'Actual: ' || a_actual.to_string_report(true) || description();
  end;

  member function failure_message_when_negated(a_actual ut_data_value) return varchar2 is
  begin
    return  'Actual: ' || a_actual.to_string_report(true) || description_when_negated();
  end;

  member procedure negated is
  begin
    is_negated_flag := ut_utils.boolean_to_int(true);
  end;

  member function negated return ut_matcher is
    l_result ut_matcher := self;
  begin
    l_result.negated();
    return l_result;
  end;

  member function is_negated return boolean is
  begin
    return coalesce(ut_utils.int_to_boolean(is_negated_flag), false);
  end;

end;
/
