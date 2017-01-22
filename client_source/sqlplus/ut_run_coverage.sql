set serveroutput on size unlimited format truncated
set trimspool on
set echo off
set termout off
set feedback off
set pagesize 0
set linesize 30000
set long 2000000
set longchunksize 100000
set verify off
set heading off

set define off
--remove previous coverage run data
--try running on windows
--$ rmdir /s /q coverage & mkdir coverage & mkdir coverage\assets & xcopy /E lib\coverage\assets coverage\assets\
$ rmdir /s /q coverage & mkdir coverage & xcopy /E lib\coverage\assets coverage\assets\ & xcopy /E lib\coverage\public coverage\public\
--try running on linus/unix
! rm -rf coverage ; mkdir coverage ; cp -R lib/coverage/assets coverage/assets



exec ut_runner.run(user||'.test_betwnstr', ut_reporters(ut_coverage_reporter()));
commit;
begin
  ut_coverage_report_html_helper.init(ut_coverage.get_coverage_data(1));
end;
/

spool coverage/ut3.betwnstr.html
  select ut_coverage_report_html_helper.get_details_file_content('UT3','BETWNSTR') from dual;
spool off

exit
