create or replace type body ut_data_value_boolean as
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

  constructor function ut_data_value_boolean(self in out nocopy ut_data_value_boolean, a_value boolean) return self as result is
  begin
    self.data_value := ut_utils.boolean_to_int(a_value);
    self.self_type  := $$plsql_unit;
    self.data_type := 'boolean';
    return;
  end;

  overriding member function is_null return boolean is
  begin
    return (self.data_value is null);
  end;

  overriding member function to_string return varchar2 is
  begin
    return ut_utils.to_string(ut_utils.int_to_boolean(self.data_value));
  end;

  overriding member function compare_implementation(a_other ut_data_value) return integer is
    l_other  ut_data_value_boolean;
    l_result integer;
  begin
    if a_other is of (ut_data_value_boolean) then
      l_other := treat(a_other as ut_data_value_boolean);
        l_result :=
          case
            when self.data_value = l_other.data_value then 0
            when self.data_value > l_other.data_value then 1
            when self.data_value < l_other.data_value then -1
          end;
    else
      raise value_error;
    end if;
    return l_result;
  end;

end;
/
