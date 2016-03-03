set serveroutput on size 1000000
set SERVEROUTPUT on size unlimited

set linesize 132
set termout off
alter session set NLS_DATE_FORMAT = 'SYYYY-MM-DD"T"HH24:MI:SS';
alter session set NLS_TIMESTAMP_FORMAT  = 'YYYY-MM-DD"T"HH:MI:SSXFF';
set termout on

DECLARE
 v_suitename varchar2(30) := 'utPLSQL_SELF';
BEGIN
utconfig.showfailuresonly (true);
utConfig.autocompile(false);   
utconfig.showconfig;

   utSuite.add (v_suitename, 'utPLSQL self test suit', rem_if_exists_in => true);

FOR x IN (
SELECT DISTINCT object_name , row_number() OVER (ORDER BY object_name) rn 
from USER_OBJECTS 
WHERE object_name LIKE UPPER(replace(utconfig.prefix,'_','#_'))||'%' ESCAPE '#'  AND object_type = 'PACKAGE' 
order by object_name
) LOOP
 DBMS_OUTPUT.PUT_LINE('adding to suite:'|| SUBSTR(X.OBJECT_NAME,length(utconfig.prefix) +1));
-- DBMS_OUTPUT.PUT_LINE('adding to suite:'|| X.OBJECT_NAME);
   UTPACKAGE.add( SUITE_IN => V_SUITENAME
                  ,PACKAGE_IN => SUBSTR(X.OBJECT_NAME,length(utconfig.prefix)+1)
                  ,SEQ_IN => X.RN
                  );
end loop;
  
  
   utPLSQL.testsuite (v_suitename, recompile_in => false);
END;
/


column UT_SUITE_NAME FORMAT A30 HEADING NAME
column ut_description format a40 word_wrapped HEADING DESCRIPTION


SELECT name ut_suite_name, 
--description ut_description,
executions, failures, last_status, last_start
FROM ut_package
WHERE suite_id IS NOT NULL
order by suite_id,seq;

SELECT NAME ut_suite_name,executions,failures,last_status FROM ut_suite;

--set return value as number of failures
set termout off
column f new_val fail_cnt
SELECT sum(failures) f FROM ut_package WHERE suite_id IS NOT NULL ;
set termout on

exit fail_cnt