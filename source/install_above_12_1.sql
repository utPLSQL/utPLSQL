/*
  utPLSQL - Version 3
  Copyright 2016 - 2026 utPLSQL Project

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

def FILE_NAME = '&&1'
column SCRIPT_NAME new_value SCRIPT_NAME noprint

VAR V_FILE_NAME VARCHAR2(1000);
begin
  if dbms_db_version.version = 12 and dbms_db_version.release >= 2
     or dbms_db_version.version > 12
  then
    :V_FILE_NAME := '&&FILE_NAME';
  else
    :V_FILE_NAME := 'dummy.sql';
  end if;
end;
/

set verify off
select :V_FILE_NAME as SCRIPT_NAME  from dual;
set termout on

set heading off
set feedback off
exec dbms_output.put_line('Installing component '||upper(regexp_substr('&&1','\/(\w*)\.',1,1,'i',1)));
@@&&SCRIPT_NAME
exec dbms_output.put_line('&&line_separator');



