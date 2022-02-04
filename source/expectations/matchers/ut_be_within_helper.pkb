create or replace package body ut_be_within_helper as
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

  function values_within_abs_distance(
    a_actual ut_data_value, a_expected ut_data_value, a_distance ut_data_value
  ) return boolean is
    l_result integer;
    l_YM_conversion varchar2(50) := case when a_distance is of (ut_data_value_yminterval) then ' year to month ' end;
    l_formula varchar2(4000);
    l_code varchar2(4000);
  begin
    l_formula :=
      case
        when a_actual is of (ut_data_value_date)
          then '( cast(greatest(l_actual, l_expected) as timestamp) - cast(least(l_actual, l_expected) as timestamp) ) '||l_YM_conversion||' <= l_distance'
        else '( greatest(l_actual, l_expected) - least(l_actual, l_expected) ) '||l_YM_conversion||' <= l_distance'
      end;
    l_code :=
    q'[
            declare
              l_actual   ]'||dbms_assert.simple_sql_name(a_actual.data_type_plsql)||  q'[ := treat(:a_actual   as ]'||dbms_assert.simple_sql_name(a_actual.self_type)||q'[).data_value;
              l_expected ]'||dbms_assert.simple_sql_name(a_expected.data_type_plsql)||q'[ := treat(:a_expected as ]'||dbms_assert.simple_sql_name(a_expected.self_type)||q'[).data_value;
              l_distance ]'||dbms_assert.simple_sql_name(a_distance.data_type_plsql)||q'[ := treat(:a_distance as ]'||dbms_assert.simple_sql_name(a_distance.self_type)||q'[).data_value;
            begin
              :result :=
                case
                  when 
                    ]'||l_formula||q'[
                  then 1
                  else 0
                end;
            end;
            ]';
    execute immediate l_code
      using a_actual, a_expected, a_distance, out l_result;
    return l_result > 0;
  end;

end;
/
