SET TERMOUT OFF
SET VERIFY OFF
SET PAGESIZE 0
SET FEEDBACK OFF
SET TRIMSPOOL ON

SET DEFINE ON
TTITLE OFF
SET SERVEROUTPUT ON SIZE 1000000 FORMAT WRAPPED

DEFINE uscript='ut_i_spool_temp.sql'

SET TERMOUT ON
PROMPT &line1
PROMPT RECOMPILING &UT OBJECTS
PROMPT &line1
SET TERMOUT OFF

SPOOL &uscript
select 'PROMPT Recompiling...' from dual;
select 'alter package '||object_name||' compile package;'
from all_objects
where owner='&ut_owner' and object_name like 'UT%' and 
  object_type=('PACKAGE')
order by created;
select 'PROMPT &finished' from dual;
SPOOL OFF
SET TERMOUT ON

@@&uscript

