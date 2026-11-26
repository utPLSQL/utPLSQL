create or replace noneditionable package body ut_test_case_values as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2026 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  type tt_values is table of ut_anydata_list index by varchar2(4000 char);
  type tt_json is table of clob index by varchar2(4000 char);
  g_values tt_values;
  g_json   tt_json;

  procedure set_values(a_test_path varchar2, a_values ut_anydata_list) is
  begin
    g_values(a_test_path) := a_values;
  end;

  function get_values(a_test_path varchar2) return ut_anydata_list is
  begin
    return case when g_values.exists(a_test_path) then g_values(a_test_path) end;
  end;

  procedure set_json(a_test_path varchar2, a_json clob) is
  begin
    g_json(a_test_path) := a_json;
  end;

  function get_json(a_test_path varchar2) return clob is
  begin
    return case when g_json.exists(a_test_path) then g_json(a_test_path) end;
  end;

  procedure remove_values(a_test_path varchar2) is
  begin
    g_values.delete(a_test_path);
    g_json.delete(a_test_path);
  end;

end;
/
