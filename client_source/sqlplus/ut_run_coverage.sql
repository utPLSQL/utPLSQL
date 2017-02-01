set serveroutput on size unlimited format truncated
set trimspool on
set echo off
set termout off
set feedback off
set pagesize 0
set linesize 30000
set long 200000000
set longchunksize 1000000
set verify off
set heading off

set define off
--remove previous coverage run data
--try running on windows
$ rmdir /s /q coverage > nul 2>&1 & mkdir coverage > nul 2>&1 & xcopy /E lib\coverage\public coverage\assets\ > nul 2>&1
--try running on linus/unix
! rm -rf coverage &>/dev/null ; mkdir coverage &>/dev/null ; cp -R lib/coverage/public coverage/assets &>/dev/null


var reporter_id varchar2(32);

declare
  l_reporter ut_coverage_html_reporter := ut_coverage_html_reporter();
begin
  :reporter_id := l_reporter.reporter_id;
  ut_runner.run(user, ut_reporters(l_reporter));
end;
/

spool coverage/index.html
 select * from table( ut_output_buffer.get_lines(:reporter_id) );
spool off

exit
