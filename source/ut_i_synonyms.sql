SET TERMOUT OFF
SET VERIFY OFF
SET PAGESIZE 0
SET FEEDBACK OFF
SET TRIMSPOOL ON

spool off
SET DEFINE ON
TTITLE OFF
SET SERVEROUTPUT ON SIZE 1000000 FORMAT WRAPPED

DEFINE uscript='ut_i_spool_temp.sql'

SET TERMOUT ON
PROMPT &line1
PROMPT CREATING SYNONYMS FOR &UT OBJECTS
PROMPT &line1
SET TERMOUT OFF

COLUMN col NOPRINT NEW_VALUE fine
select count(privilege) col from session_privs where privilege='CREATE PUBLIC SYNONYM';

SPOOL &uscript
select decode(&fine,0,'','PROMPT Creating synonyms for packages...') from dual;
select decode(&fine,0,'','create public synonym '||object_name||' for '||object_name||';')
from all_objects
where owner='&ut_owner' and object_name like 'UT%' and 
  object_type in ('PACKAGE','TABLE','VIEW','SEQUENCE');
select decode(&fine,0,'','PROMPT &finished') from dual;

select decode(&fine,1,'','PROMPT Skipped - user has no rights to create public synonyms') from dual;
SPOOL OFF
SET TERMOUT ON

@@&uscript
