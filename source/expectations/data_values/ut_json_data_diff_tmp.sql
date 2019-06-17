create global temporary table ut_json_data_diff_tmp(
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2018 utPLSQL Project
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
  diff_id           raw(128),
  difference_type   varchar2(250),
  act_element_name  varchar2(2000),
  act_element_value varchar2(4000),
  act_json_type     varchar2(100),
  act_access_path   varchar2(4000),
  act_parent_path   varchar2(4000),
  exp_element_name  varchar2(2000),
  exp_element_value varchar2(4000),
  exp_json_type     varchar2(2000),
  exp_access_path   varchar2(4000),
  exp_parent_path   varchar2(4000)
) on commit preserve rows;
