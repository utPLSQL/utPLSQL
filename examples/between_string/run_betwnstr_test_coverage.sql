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
spool coverage.html
exec ut.run(user, ut_coverage_html_reporter(a_project_name=>'Demo of between string function tests', a_include_object_list=>ut_varchar2_list('ut3.betwnstr')));
spool off


drop package test_betwnstr;
drop function betwnstr;

exit
