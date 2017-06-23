set heading off
set feedback off
exec dbms_output.put_line('Installing component '||upper(regexp_substr('&&1','\/(\w*)\.',1,1,'i',1)));
@@&&1
show errors
exec dbms_output.put_line('--------------------------------------------------------------');

