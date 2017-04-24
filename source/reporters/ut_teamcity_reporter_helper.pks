create or replace package ut_teamcity_reporter_helper is
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

--   function block_opened(a_name varchar2, a_flow_id varchar2 default null) return varchar2;
--   function block_closed(a_name varchar2, a_flow_id varchar2 default null) return varchar2;

  function test_suite_started(a_suite_name varchar2, a_flow_id varchar2 default null) return varchar2;
  function test_suite_finished(a_suite_name varchar2, a_flow_id varchar2 default null) return varchar2;

  function test_started(a_test_name varchar2, a_capture_standard_output boolean default null, a_flow_id varchar2 default null) return varchar2;
  function test_finished(a_test_name varchar2, a_test_duration_milisec number default null, a_flow_id varchar2 default null) return varchar2;
  function test_disabled(a_test_name varchar2, a_flow_id varchar2 default null) return varchar2;
  function test_failed(a_test_name varchar2, a_msg in varchar2 default null, a_details varchar2 default null, a_flow_id varchar2 default null, a_actual varchar2 default null, a_expected varchar2 default null) return varchar2;
--   function test_std_out(a_test_name varchar2, a_out in varchar2, a_flow_id in varchar2 default null) return varchar2;
  function test_std_err(a_test_name varchar2, a_out in varchar2, a_flow_id in varchar2 default null) return varchar2;

--   function custom_message(a_text in varchar2, a_status in varchar2, a_error_deatils in varchar2 default null, a_flow_id in varchar2 default null) return varchar2;

end ut_teamcity_reporter_helper;
/
