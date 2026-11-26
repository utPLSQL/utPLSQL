create or replace noneditionable package ut_test_case_values authid definer as
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

  /**
   * Holds the argument values of --%testcasesource test cases from the moment a test is split into its
   * test cases until each test case has run: the row values of a cursor as ANYDATA, or the JSON text of a JSON test case.
   * The values can't be attributes of the suite item types, as those types are stored and queried with SQL,
   * which doesn't allow ANYDATA in collections, and the JSON text can be longer than a varchar2 attribute.
   */

  procedure set_values(a_test_path varchar2, a_values ut_anydata_list);

  function get_values(a_test_path varchar2) return ut_anydata_list;

  procedure set_json(a_test_path varchar2, a_json clob);

  function get_json(a_test_path varchar2) return clob;

  procedure remove_values(a_test_path varchar2);

end;
/
