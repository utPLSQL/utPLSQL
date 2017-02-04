create table ut_output_buffer_tmp(
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
  * This table is not a global temporary table as it needs to allow cross-session data exchange
  * It is used however as a temporary table with multiple writers.
  * This is why it has very high initrans and has nologging
  */
  reporter_id    raw(32) not null,
  message_id     number(38,0) not null,
  text           varchar2(4000),
  is_finished    number(1,0) default 0 not null,
  start_date     date not null,
  constraint ut_output_buffer_tmp_pk primary key(start_date, reporter_id, message_id),
  constraint ut_output_buffer_tmp_ck check(is_finished = 0 and text is not null or is_finished = 1 and text is null)
) nologging nomonitoring initrans 100
;

create index ut_output_buffer_tmp_i on ut_output_buffer_tmp(start_date) initrans 100 nologging;
