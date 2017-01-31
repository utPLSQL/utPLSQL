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

--Below lines do the following:
-- - remove previous coverage data,
-- - create coverage directory,
-- - populate assets for coverage html report
set define off
set termout off
--try running on windows
$ rmdir /s /q coverage & mkdir coverage & xcopy /E ..\..\client_source\sqlplus\lib\coverage\assets coverage\assets\ & xcopy /E ..\..\client_source\sqlplus\lib\coverage\public coverage\assets\ & move index.html coverage/
--try running on linus/unix
! rm -rf coverage ; mkdir coverage ; cp -R ../../client_source/sqlplus/lib/coverage/assets coverage/assets ; cp -R ../../client_source/sqlplus/lib/coverage/public coverage/assets ;  mv index.html coverage/
set termout on

drop package test_betwnstr;
drop function betwnstr;

exit
