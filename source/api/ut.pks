create or replace package ut authid current_user as

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

  function version return varchar2;

  function expect(a_actual in anydata, a_message varchar2 := null) return ut_expectation_anydata;

  function expect(a_actual in blob, a_message varchar2 := null) return ut_expectation_blob;

  function expect(a_actual in boolean, a_message varchar2 := null) return ut_expectation_boolean;

  function expect(a_actual in clob, a_message varchar2 := null) return ut_expectation_clob;

  function expect(a_actual in date, a_message varchar2 := null) return ut_expectation_date;

  function expect(a_actual in number, a_message varchar2 := null) return ut_expectation_number;

  function expect(a_actual in sys_refcursor, a_message varchar2 := null) return ut_expectation_refcursor;

  function expect(a_actual in timestamp_unconstrained, a_message varchar2 := null) return ut_expectation_timestamp;

  function expect(a_actual in timestamp_ltz_unconstrained, a_message varchar2 := null) return ut_expectation_timestamp_ltz;

  function expect(a_actual in timestamp_tz_unconstrained, a_message varchar2 := null) return ut_expectation_timestamp_tz;

  function expect(a_actual in varchar2, a_message varchar2 := null) return ut_expectation_varchar2;

  function expect(a_actual in yminterval_unconstrained, a_message varchar2 := null) return ut_expectation_yminterval;

  function expect(a_actual in dsinterval_unconstrained, a_message varchar2 := null) return ut_expectation_dsinterval;

  procedure fail(a_message in varchar2);

  function run(a_reporter ut_reporter_base := ut_documentation_reporter(), a_color_console integer := 0) return ut_varchar2_rows pipelined;

  function run(a_paths ut_varchar2_list, a_reporter ut_reporter_base := ut_documentation_reporter(), a_color_console integer := 0) return ut_varchar2_rows pipelined;

  function run(a_path varchar2, a_reporter ut_reporter_base := ut_documentation_reporter(), a_color_console integer := 0) return ut_varchar2_rows pipelined;

  procedure run(a_reporter ut_reporter_base := ut_documentation_reporter(), a_color_console boolean := false);

  procedure run(a_paths ut_varchar2_list, a_reporter ut_reporter_base := ut_documentation_reporter(), a_color_console boolean := false);

  procedure run(a_path varchar2, a_reporter ut_reporter_base := ut_documentation_reporter(), a_color_console boolean := false);

  /*
    Helper procedure to set NLS session parameter for date processing in refcursor.
    It needs to be called before refcursor is open in order to have DATE data type data in refcursor
     properly transformed into XML format as a date-time element.
    If the function is not called before opening a cursor to be compared, the DATE data is compared using default NLS setting for date.
  */
  procedure set_nls;

  /*
    Helper procedure to reset NLS session parameter to it's original state.
    It needs to be called after refcursor is open in order restore the original session state and keep the NLS date setting at default.
  */
  procedure reset_nls;

end ut;
/
