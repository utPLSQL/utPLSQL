create or replace type body ut_contain as
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

  constructor function ut_contain(self in out nocopy ut_contain, a_expected sys_refcursor) return self as result is
  begin
    self.init(ut_data_value_refcursor(a_expected), null, $$plsql_unit);
    self.options.unordered();
    return;
  end;

  overriding member function run_matcher(self in out nocopy ut_contain, a_actual ut_data_value) return boolean is
    l_result boolean;
  begin
    if self.expected.data_type = a_actual.data_type then
      l_result :=
        ( 0
          = treat( self.expected as ut_data_value_refcursor )
            .compare_implementation( a_actual, self.options, true, self.is_negated() )
        );
    else
      l_result := (self as ut_matcher).run_matcher(a_actual);
    end if;
    return l_result;
  end;

  overriding member function run_matcher_negated(self in out nocopy ut_contain, a_actual ut_data_value) return boolean is
  begin
    return run_matcher(a_actual);
  end;

  overriding member function failure_message(a_actual ut_data_value) return varchar2 is
    l_result varchar2(32767);
  begin
    if self.expected.data_type = a_actual.data_type and self.expected.is_diffable then
      l_result :=
        'Actual: '||a_actual.get_object_info()||' '||self.description()||': '||self.expected.get_object_info()
        ||  chr(10) || 'Diff:'
        ||  treat(expected as ut_data_value_refcursor).diff( a_actual, self.options );
    else
      l_result := (self as ut_matcher).failure_message(a_actual) || ': '|| self.expected.to_string_report();
    end if;
    return l_result;
  end;

  overriding member function failure_message_when_negated(a_actual ut_data_value) return varchar2 is
    l_result varchar2(32767);
  begin
    return (self as ut_matcher).failure_message_when_negated(a_actual) || ':'|| expected.to_string_report();
  end;
  
end;
/
