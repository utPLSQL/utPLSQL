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
PROMPT GRANTS FOR &UT OBJECTS
PROMPT &line1
SET TERMOUT OFF

SPOOL &uscript

select 'PROMPT Granting all on every object...' from dual;
select 'grant all on '||object_name||' to public;'
from all_objects
where owner='&ut_owner' and object_name like 'UT%' and 
  object_type in('TABLE','SEQUENCE','PACKAGE', 'VIEW');
select 'PROMPT &finished' from dual;

select 'PROMPT Granting execute on packages...' from dual;
select 'grant execute on '||object_name||' to public;'
from all_objects
where owner='&ut_owner' and object_name like 'UT%' and 
  object_type ='PACKAGE';

select 'PROMPT &finished' from dual;

SPOOL OFF
SET TERMOUT ON

@@&uscript

