set define off
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

alter session set plsql_optimize_level=0;

set linesize 200
set define on
set verify off

prompt Empowering UT3_TESTER to UT3_OWNER objects

begin
  for i in ( select object_name from all_objects t 
    where t.object_type in ('PACKAGE','TYPE') 
    and owner = 'UT3'
    and generated = 'N'
    and lower(object_name) not like 'sys%')
  loop
    execute immediate 'grant execute on ut3."'||i.object_name||'" to UT3_TESTER';
  end loop;
end;
/

prompt Empowering UT3_TESTER to UT3_OWNER tables

begin
  for i in ( select table_name from all_tables t where  owner = 'UT3' and nested = 'NO' and IOT_TYPE is NULL)
  loop
    execute immediate 'grant select on UT3.'||i.table_name||' to UT3_TESTER';
  end loop;
end;
/

exit;
