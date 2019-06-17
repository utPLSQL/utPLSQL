create table ut_output_buffer_info_tmp(
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
  /*
  * This table is not a global temporary table as it needs to allow cross-session data exchange
  * It is used however as a temporary table with multiple writers.
  * This is why it has very high initrans and has nologging
  */
  output_id      raw(32) not null,
  start_date     date not null,
  constraint ut_output_buffer_info_tmp_pk primary key(output_id)
) organization index nologging initrans 10
;

