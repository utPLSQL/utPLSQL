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

set echo off
set verify off
column 1 new_value 1 noprint;
column 2 new_value 2 noprint;
column 3 new_value 3 noprint;
select null as "1", null as "2" , null as "3" from dual where 1=0;
column sep new_value sep noprint
select '--------------------------------------------------------------' as sep from dual;

column ut3_owner      new_value ut3_owner      noprint
column ut3_password   new_value ut3_password   noprint
column ut3_tablespace new_value ut3_tablespace noprint

select coalesce('&&1','UT3') ut3_owner,
       coalesce('&&2','XNtxj8eEgA6X6b6f') ut3_password,
       coalesce('&&3','users') ut3_tablespace
  from dual;
