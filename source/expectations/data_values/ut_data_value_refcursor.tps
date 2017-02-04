create or replace type ut_data_value_refcursor under ut_data_value(
  /*
  utPLSQL - Version X.X.X.X 
  Copyright 2016 - 2017 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */
  /*
    class: ut_data_value_refcursor

    Holds information about ref cursor to be processed by expectation
  */


  /*
    var: data_value

    Holds a dbms_xmlgen context for a cursor obtained by calling dbms_xmlgen.newContext(sys_refcursor)
  */
  data_value number,

  /*
    function: ut_data_value_refcursor

    constructor function that builds a cursor from a sql_statement that was passed in
  */
  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor) return self as result,

  /*
    function: ut_data_value_refcursor

    constructor function that builds a cursor from a sql_statement that was passed in
  */
  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value varchar2) return self as result,

  overriding member function is_null return boolean,

  overriding member function to_string return varchar2
)
/
