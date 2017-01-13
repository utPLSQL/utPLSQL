whenever sqlerror exit failure rollback
whenever oserror exit failure rollback
set echo off
set feedback off
set heading off
set verify off

define ut3_user       = &1
define ut3_password   = &2
define ut3_tablespace = &3

create user &ut3_user identified by &ut3_password default tablespace &ut3_tablespace quota unlimited on &ut3_tablespace;

grant create session, create procedure, create type, create table, create synonym to &ut3_user;

grant execute on dbms_pipe to &ut3_user;
grant create job to &ut3_user;

grant alter session to &ut3_user;

--only needed to run unit tests for utplsql v3, not required to run utplsql v3 itself
grant select any dictionary to &ut3_user;

exit success
