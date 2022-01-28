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
    a_value_1 ut_data_value, a_value_2 ut_data_value, a_distance ut_data_value
  ) return boolean is
    l_result integer;
  begin
    execute immediate q'[
            begin
              :result :=
                case
                  when
                    treat(:a_value_1 as ]'||dbms_assert.simple_sql_name(a_value_1.self_type)||q'[).data_value
                      between
                        treat(:a_value_2 as ]'||dbms_assert.simple_sql_name(a_value_2.self_type)||q'[).data_value
                        - treat(:a_distance as ]'||dbms_assert.simple_sql_name(a_distance.self_type)||q'[).data_value
                      and
                        treat(:a_value_2 as ]'||dbms_assert.simple_sql_name(a_value_2.self_type)||q'[).data_value
                        + treat(:a_distance as ]'||dbms_assert.simple_sql_name(a_distance.self_type)||q'[).data_value
                  then 1
                  else 0
                end;
            end;
            ]'
      using out l_result, a_value_1, a_value_2, a_distance;
    return l_result > 0;
  end;

end;
/
