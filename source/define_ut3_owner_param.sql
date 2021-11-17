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
set serveroutput on size unlimited format truncated
whenever oserror continue

set heading off
set linesize 1000
set pagesize 0

set verify off
set define on

set termout off
set timing off
set feedback off

column line_separator new_value line_separator noprint
select '--------------------------------------------------------------' as line_separator from dual;

column 1 new_value 1 noprint
select null as "1" from dual where 1=0;
spool params.sql.tmp
select
  case
    when '&&1' is null then q'[ACCEPT ut3_owner CHAR DEFAULT 'UT3' PROMPT 'Provide schema for the utPLSQL v3 (UT3)']'
    else 'define ut3_owner=&&1'
  end
from dual;
spool off
set termout on
@params.sql.tmp
set termout off
/* cleanup temporary sql files */
--try running on windows
$ del params.sql.tmp
--try running on linux/unix
! rm params.sql.tmp
set termout on
