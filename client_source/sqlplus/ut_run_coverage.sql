set serveroutput on size unlimited format truncated
set trimspool on
set echo off
set termout off
set feedback off
set define off
set pagesize 0
set linesize 30000
set long 2000000
set longchunksize 100000
set verify off
set heading off

--remove previous coverage run data
--try running on windows
$ rmdir /s /q coverage & mkdir coverage
--try running on linus/unix
! rm -rf coverage ; mkdir coverage

spool get_static_files.sql

declare
  l_file_names ut_varchar2_list;
begin
  l_file_names := ut_coverage_report_html_helper.get_static_file_names();
  for i in 1 .. l_file_names.count loop
    dbms_output.put_line('spool coverage/'||l_file_names(i));
    dbms_output.put_line('select ut_coverage_report_html_helper.get_static_file('''||l_file_names(i)||''') from dual;');
    dbms_output.put_line('spool off');
  end loop;
end;
/

spool off

@@get_static_files.sql

exec ut_runner.run(user||'.test_betwnstr', ut_coverage_reporter());

begin
  ut_coverage_report_html_helper.init(ut_coverage.get_coverage_data(1));
end;
/

spool coverage/aa.html
  select ut_coverage_report_html_helper.get_details_file_content('UT3','BETWNSTR') from dual;
spool off

--try running on windows
$ del get_static_files.sql
--try running on linus/unix
! rm get_static_files.sql


exit
