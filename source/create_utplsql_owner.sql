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
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback
set echo off
set feedback off
set heading off
set verify off

define ut3_user       = &1
define ut3_password   = &2
define ut3_tablespace = &3

prompt Creating utPLSQL user &&ut3_user

create user &ut3_user identified by "&ut3_password" default tablespace &ut3_tablespace quota unlimited on &ut3_tablespace;

grant create session, create sequence, create procedure, create type, create table, create view, create synonym to &ut3_user;

begin
  $if dbms_db_version.version < 18 $then
    execute immediate 'grant execute on dbms_lock to &ut3_user';
  $else
    null;
  $end
end;
/

grant execute on dbms_crypto to &ut3_user;

grant alter session to &ut3_user;

