set trimspool on
set linesize 32767
set pagesize 0
set long 200000000
set longchunksize 1000000
@@betwnstr.sql
@@test_betwnstr.pkg

set serveroutput on size unlimited format truncated

set feedback off
set termout  off
spool index.html
exec ut.run(user, ut_coverage_html_reporter('Demo of between string function tests'));
spool off

--Below lines do the following:
-- - remove previous coverage data,
-- - create coverage directory,
-- - populate assets for coverage html report
set define off
set termout off
--try running on windows
$ rmdir /s /q coverage > nul 2>&1 & mkdir coverage > nul 2>&1 & xcopy /E ..\..\client_source\sqlplus\lib\coverage\assets coverage\assets\ > nul 2>&1 & xcopy /E ..\..\client_source\sqlplus\lib\coverage\public coverage\assets\ > nul 2>&1 & move index.html coverage/ > nul 2>&1
--try running on linus/unix
! rm -rf coverage &>/dev/null ; mkdir coverage &>/dev/null ; cp -R ../../client_source/sqlplus/lib/coverage/assets coverage/assets &>/dev/null ; cp -R ../../client_source/sqlplus/lib/coverage/public coverage/assets &>/dev/null ;  mv index.html coverage/ &>/dev/null
set termout on

drop package test_betwnstr;
drop function betwnstr;

exit
