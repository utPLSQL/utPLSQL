SET TERMOUT OFF
SET VERIFY OFF
SET PAGESIZE 0
SET FEEDBACK OFF
SET TRIMSPOOL ON

SET DEFINE ON
TTITLE OFF
SET SERVEROUTPUT ON SIZE 1000000 FORMAT WRAPPED

DEFINE uscript='ut_i_spool_temp.sql'

COLUMN col NOPRINT NEW_VALUE ut_owner
SELECT USER col FROM DUAL;

DEFINE line1='-------------------------------------------------------------'
DEFINE line2='============================================================='
DEFINE finished='.                            Finished'


SPOOL &uscript

REM synonyms: --------------------------------------------------------------

COLUMN col NOPRINT NEW_VALUE fine
SELECT COUNT (PRIVILEGE) col
  FROM session_privs
 WHERE PRIVILEGE = 'DROP PUBLIC SYNONYM';

SELECT DECODE (&fine
             , 0, ''
             , 'PROMPT Dropping &UT public synonyms...'
              )
  FROM DUAL;

SELECT DECODE (&fine
             , 0, ''
             , 'drop public synonym ' || o1.object_name || ';'
              )
  FROM all_objects o1, all_objects o2
 WHERE o1.owner = 'PUBLIC'
   AND o1.object_type = 'SYNONYM'
   AND o1.object_name = o2.object_name
   AND o1.object_name LIKE 'UT%'
   AND o2.object_type IN ('PACKAGE', 'TABLE', 'VIEW','SEQUENCE')
   AND o2.owner = '&ut_owner';

SELECT DECODE (&fine, 0, '', 'PROMPT &finished')
  FROM DUAL;

REM tables: ----------------------------------------------------------------

SELECT 'PROMPT Dropping &UT tables...'
  FROM DUAL;

SELECT 'drop table ' || object_name || ' cascade constraints;'
  FROM all_objects
 WHERE owner = '&ut_owner'
   AND object_name LIKE 'UT%'
   AND object_type = 'TABLE';

SELECT 'PROMPT &finished'
  FROM DUAL;

REM views: ----------------------------------------------------------------

SELECT 'PROMPT Dropping &UT views...'
  FROM DUAL;

SELECT 'drop view ' || object_name || ' cascade constraints;'
  FROM all_objects
 WHERE owner = '&ut_owner'
   AND object_name LIKE 'UT%'
   AND object_type = 'VIEW';

SELECT 'PROMPT &finished'
  FROM DUAL;

REM sequences: --------------------------------------------------------------

SELECT 'PROMPT Dropping &UT sequences...'
  FROM DUAL;

SELECT 'drop sequence ' || object_name || ';'
  FROM all_objects
 WHERE owner = '&ut_owner'
   AND object_name LIKE 'UT%'
   AND object_type = 'SEQUENCE';

SELECT 'PROMPT &finished'
  FROM DUAL;

REM sequences: --------------------------------------------------------------

SELECT 'PROMPT Dropping &UT packages...'
  FROM DUAL;

SELECT 'drop package ' || object_name || ';'
  FROM all_objects
 WHERE owner = '&ut_owner'
   AND object_name LIKE 'UT%'
   AND object_type = 'PACKAGE';

SELECT 'PROMPT &finished'
  FROM DUAL;


SPOOL OFF
SET TERMOUT ON

@@&uscript
