whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

set echo off
set feedback off
set heading off
set verify off

--make SQLPLUS parameters optional
column 1 new_value 1
column 2 new_value 2
column 3 new_value 3
select '' "1", '' "2", '' "3" from dual where rownum = 0;


column ut3_user       new_value ut3_user
column ut3_pass       new_value ut3_pass
column ut3_tablespace new_value ut3_tablespace
--do not show the values
set termout off
select nvl('&&1', default_user) as ut3_user,
       nvl('&&2', default_pass) as ut3_pass,
       nvl('&&3', default_ts) as ut3_tablespace
  from (select 'ut3'   as default_user,
               'ut3'   as default_pass,
               'users' as default_ts
          from dual);

create user &ut3_user identified by &ut3_pass default tablespace &ut3_tablespace;

grant create session, create procedure, create type, create table to &ut3_user;

exit success
