create global temporary table ut_coverage_sources_tmp(
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
  full_name varchar2(4000),
  owner varchar2(250),
  name  varchar2(250),
  type  varchar2(250),
  line  number(38,0),
  to_be_skipped varchar2(1),
  text varchar2(4000),
  constraint ut_coverage_sources_tmp_pk primary key (owner,name,type,line)
) on commit preserve rows;

--is this needed?
--create unique index ut_coverage_sources_tmp_uk on ut_coverage_sources_tmp$ (owner,name,to_be_skipped, line);
