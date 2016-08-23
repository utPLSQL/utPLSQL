whenever sqlerror exit failure rollback
whenever oserror exit failure rollback
set echo off
set feedback off
set heading off
set verify off

define ut3_user       = &1
define ut3_pass       = &2
define ut3_tablespace = &3

create user &ut3_user identified by &ut3_pass default tablespace &ut3_tablespace quota unlimited on &ut3_tablespace;

grant create session, create procedure, create type, create table to &ut3_user;

exit success
