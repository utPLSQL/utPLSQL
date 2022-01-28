create or replace type ut_run_info under ut_event_item (
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project

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
  ut_version           varchar2(4000),
  db_version           varchar2(4000),
  db_compatibility     varchar2(4000),
  db_os_type           varchar2(4000),
  db_component_version ut_key_value_pairs,
  nls_session_params   ut_key_value_pairs,
  nls_instance_params  ut_key_value_pairs,
  nls_db_params        ut_key_value_pairs,
  constructor function ut_run_info(self in out nocopy ut_run_info) return self as result
);
/
