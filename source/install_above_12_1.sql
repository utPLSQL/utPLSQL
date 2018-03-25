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



