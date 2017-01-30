set trimspool on
set linesize 32767
set pagesize 0
set long 200000000
set longchunksize 1000000
@@betwnstr.sql
@@test_betwnstr.pkg

set serveroutput on size unlimited format truncated

set feedback off
spool index.html
exec ut.run(user||'.test_betwnstr', ut_coverage_html_reporter());
spool off
set define off
--remove previous coverage run data
--try running on windows
$ rmdir /s /q coverage > nul 2>&1 & mkdir coverage > nul 2>&1 & xcopy /E ..\..\client_source\sqlplus\lib\coverage\assets coverage\assets\ > nul 2>&1 & xcopy /E ..\..\client_source\sqlplus\lib\coverage\public coverage\assets\ > nul 2>&1 & move index.html coverage/ > nul 2>&1
--try running on linus/unix
! rm -rf coverage ; mkdir coverage ; cp -R ../../client_source/sqlplus/lib/coverage/assets coverage/assets ; cp -R ../../client_source/sqlplus/lib/coverage/public coverage/assets ;  mv index.html coverage/

drop package test_betwnstr;
drop function betwnstr;

exit
