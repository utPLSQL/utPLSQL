create global temporary table ut_data_set_tmp(
  /*
  utPLSQL - Version 3
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
  data_set_guid    raw(16),
  item_no          integer,
  item_data        xmltype,
  constraint ut_data_set_tmp_pk primary key(data_set_guid, item_no)
) on commit preserve rows;
