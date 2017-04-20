create or replace package ut_expectation_processor authid current_user as
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

  gc_default_nulls_are_equal constant boolean := true;

  subtype boolean_not_null is boolean not null;

  function nulls_are_equal return boolean;

  procedure nulls_are_equal(a_setting boolean_not_null);

  function get_aggregate_asserts_result return integer;

  procedure clear_asserts;

  function get_asserts_results return ut_expectation_results;

  procedure add_assert_result(a_assert_result ut_expectation_result);

  procedure report_failure(a_message in varchar2);

  procedure set_xml_nls_params;

  procedure reset_nls_params;

  -- function is looking at call stack
  -- and tries to figure out at which line of code
  -- in a unit test, the expectation was called
  -- if found, it returns a text:
  --   at: owner.name:line "source code line text"
  -- The text is to be consumed by expectation result
  function who_called_expectation return varchar2;

end;
/
