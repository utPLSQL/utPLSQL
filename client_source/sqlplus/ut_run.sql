/**
  This script is designed to allow invocation of UTPLSQL with multiple reporters.
  It allows saving of outcomes into multiple output files.
  It also facilitates displaying on screen unit test results while the execution is still ongoing.
  Current limit of script parameters is 39

Scrip invocation:
  ut_run.sql user/password@database [-p=(ut_path|ut_paths)] [-c] [-f=format [-o=output] [-s] ...]

Parameters:
  user         - username to connect as
  password     - password of the user
  database     - database to connect to
  -p=ut_path(s)- A path or a comma separated list of paths to unit test to be executed.
                 The path can be in one of the following formats:
                   schema[.package[.procedure]]
                   schema:suite[.suite[.suite][...]][.procedure]
                 Both formats can be mixed in the comma separated list.
                 If only schema is provided, then all suites owner by that schema (user) are executed.
                 If -p is omitted, the current schema is used.
  -f=format    - A reporter to be used for reporting.
                 Available options:
                   -f=ut_documentation_reporter
                     A textual pretty-print of unit test results (usually use for console output)
                   -f=ut_teamcity_reporter
                     A teamcity Unit Test reporter, that can be used to visualize progress of test execution as the job progresses.
                   -f=ut_xunit_reporter
                     A XUnit xml format (as defined at: http://stackoverflow.com/a/9691131 and at https://gist.github.com/kuzuha/232902acab1344d6b578)
                     Usually used  by Continuous Integration servers like Jenkins/Hudson or Teamcity to display test results.
                 If no -f option is provided, the ut_documentation_reporter will be used.

  -o=output    - file name to save the output provided by the reporter.
                 If defined, the output is not displayed on screen by default. This can be changed with the -s parameter.
                 If not defined, then output will be displayed on screen, even if the parameter -s is not specified.
                 If more than one -o parameter is specified for one -f parameter, the last one is taken into consideration.
  -s           - Forces putting output to to screen for a given -f parameter.
  -c           - If specified, enables printing of test results in colors as defined by ANSICONSOLE standards

  Parameters -f, -o, -s are correlated. That is parameters -o and -s are defining outputs for -f.
  Examples of invocation using sqlplus from command line:

    sqlplus /nolog @ut_run hr/hr@xe -p=hr_test -f=ut_documentation_reporter -o=run.log -s -f=ut_teamcity_reporter -o=teamcity.xml

      All Unit tests from schema "hr_test" will be be invoked with two reporters:
      - ut_documentation_reporter - will output to screen and save it's output to file "run.log"
      - ut_teamcity_reporter - will save it's output to file "teamcity.xml"

    sqlplus /nolog @ut_run hr/hr@xe

      All Unit tests from schema "hr" will be be invoked with ut_documentation_reporter as a format and the results will be printed to screen

 */

whenever sqlerror exit failure
whenever oserror exit failure
conn &1
whenever sqlerror continue
whenever oserror continue

set serveroutput on size unlimited format truncated
set trimspool on
set echo off
set termout off
set feedback off
set pagesize 0
set linesize 30000
set long 30000
set longchunksize 30000
set verify off
set heading off


-------------------------------------------------
-- Making SQLPlus parameters options
-------------------------------------------------
set define off
spool make_input_params_optional.sql.tmp
declare
  l_sql_columns varchar2(4000);
begin
  for i in 1 .. 100 loop
    dbms_output.put_line('column '||i||' new_value '||i);
    l_sql_columns := l_sql_columns ||'null as "'||i||'",';
  end loop;
  dbms_output.put_line('select '||rtrim(l_sql_columns, ',') ||' from dual where rownum = 0;');
end;
/
spool off
set define &

@@make_input_params_optional.sql.tmp


--prepare executor scripts

-------------------------------------------------
-- Defining reporter objects
-------------------------------------------------


-------------------------------------------------
-- Preparing for execution (in background)
-------------------------------------------------


set define off
spool set_run_params.sql.tmp
declare
  l_params      varchar2(4000);
begin
  for i in 1 .. 100 loop
    l_params := l_params || '''&&'||i||''',';
  end loop;
  dbms_output.put_line('exec ut_runner.set_run_params(ut_varchar2_list('||rtrim(l_params, ',')||'));' );
end;
/
spool off
set define &

@@set_run_params.sql.tmp

spool run_in_backgroung.sql.tmp
declare
  l_run_params  ut_runner.t_run_params :=  ut_runner.get_run_params();
  l_color_enabled varchar2(5) := case when l_run_params.color_enabled then 'true' else 'false' end;
  procedure p(a_text varchar2) is
  begin
    dbms_output.put_line(a_text);
  end;
begin
  p(  'set serveroutput on size unlimited format truncated');
  p(  'set trimspool on');
  p(  'set pagesize 0');
  p(  'set linesize 4000');
  p(  'spool ut_run.dbms_output.log');
  p(  'declare');
  p(  '  v_reporter       ut_reporter_base;');
  p(  '  v_reporters_list ut_reporters := ut_reporters();');
  p(  'begin');
  if l_run_params.call_params is not null then
    for i in 1 .. l_run_params.call_params.count loop
      p('  v_reporter := '||l_run_params.call_params(i).ut_reporter_name||'();');
      p('  v_reporter.reporter_id := '''||l_run_params.call_params(i).reporter_id||''';');
      p('  v_reporters_list.extend; v_reporters_list(v_reporters_list.last) := v_reporter;');
    end loop;
  end if;
  p(  '  ut_runner.run( ut_varchar2_list('||l_run_params.ut_paths||'), v_reporters_list, a_color_console => '||l_color_enabled||' );');
  p(  'end;');
  p(  '/');
  p(  'spool off');
  p(  'exit');
end;
/
spool off

spool gather_data_from_outputs.sql.tmp
declare
  l_run_params  ut_runner.t_run_params := ut_runner.get_run_params();
  l_need_spool  boolean;
  procedure p(a_text varchar2) is
  begin
    dbms_output.put_line(a_text);
  end;
begin
  p('declare l_date date := sysdate; begin loop exit when l_date < sysdate; end loop; end;');
  p('/');
  if l_run_params.call_params is not null then
    for i in 1 .. l_run_params.call_params.count loop
      p('set termout '||l_run_params.call_params(i).output_to_screen);
      l_need_spool := (l_run_params.call_params(i).output_file_name is not null);
      p(case when l_need_spool then 'spool '||l_run_params.call_params(i).output_file_name||chr(10) end||
        'select * from table( ut_output_buffer.get_lines('''||l_run_params.call_params(i).reporter_id||''') );'||
        case when l_need_spool then chr(10)||'spool off' end);
    end loop;
  end if;
end;
/

spool off
set termout off
set define #
--try running on windows
$ start sqlplus ##1 @run_in_backgroung.sql.tmp
--try running on linus/unix
! sqlplus ##1 @run_in_backgroung.sql.tmp &
set define &
set termout on
--make sure we fetch row by row to indicate the progress
set arraysize 1
@gather_data_from_outputs.sql.tmp

set termout off
--cleanup temporary sql files
--try running on windows
$ del *.sql.tmp
--try running on linus/unix
! rm *.sql.tmp
set termout on

exit
