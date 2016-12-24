/**
  This script is designed to allow invocation of UTPLSQL with multiple reporters.
  It allows saving of outcomes into multiple output files.
  It also facilitates displaying on screen unit test results while the execution is still ongoing.
  Current limit of script parameters is 39

Scrip invocation:
  ut_run.sql user password database [ut_path|ut_paths] (-f=format [-o=output] [-s] ...)

Parameters:
  user     - username to connect as
  password - password of the user
  database - database to connect to
  ut_path  - a path(s) ot unit test(s) to be executed: user[.package[.procedure]]
  ut_paths - a comma separated list of ut_path (with no spaces in between)
  -f=format - a format to be used for reporting
  -o=output - a file name to put the outputs into
  -s         - put output to screen can be used in combination with -o

  Parameters -f, -o, -s are correlated. That is parameters -o and -s are defining outputs for -f.
  Example:
    ut_run hr hr xe hr -f=ut_documentation_reporter -o=run.log -s -f=ut_teamcity_reporter -o=teamcity.xml
  Unit tests will be be invoked with two reporters:
  - ut_documentation_reporter - this one will output to screen and into file "run.log"
  - ut_teamcity_reporter - this one will output to file "teamcity.xml"
 */

whenever sqlerror exit failure
whenever oserror exit failure
conn &1/&2@&3
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

set define off
spool make_input_params_optional.sql
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

@@make_input_params_optional.sql


--prepare executor scripts

set define off
spool set_run_params.sql
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


@@set_run_params.sql


spool run_in_backgroung.sql
declare
  l_output_type varchar2(256) := ut_runner.get_streamed_output_type_name();
  l_run_params  ut_runner.t_run_params :=  ut_runner.get_run_params();
  procedure p(a_text varchar2) is
  begin
    dbms_output.put_line(a_text);
  end;
begin
  p(  'set serveroutput on size unlimited format truncated');
  p(  'set trimspool on');
  p(  'set pagesize 0');
  p(  'set linesize 4000');
  p(  'spool run_background.log');
  p(  'declare');
  p(  '  v_reporter       ut_reporter;');
  p(  '  v_reporters_list ut_reporters_list := ut_reporters_list();');
  p(  'begin');
  for i in 1 .. cardinality(l_run_params.call_params) loop
    p('  v_reporter := '||l_run_params.call_params(i).ut_reporter_name||'('||l_output_type||'());');
    p('  v_reporter.output.output_id := '''||l_run_params.call_params(i).output_id||''';');
    p('  v_reporters_list.extend; v_reporters_list(v_reporters_list.last) := v_reporter;');
  end loop;
  p(  '  ut.run( ut_varchar2_list('||l_run_params.ut_paths||'), ut_composite_reporter( v_reporters_list ) );');
  p(  'end;');
  p(  '/');
  p(  'spool off');
  p(  'exit');
end;
/
spool off

spool gather_data_from_outputs.sql
declare
  l_output_type varchar2(256) := ut_runner.get_streamed_output_type_name();
  l_run_params  ut_runner.t_run_params := ut_runner.get_run_params();
  l_need_spool  boolean;
  procedure p(a_text varchar2) is
  begin
    dbms_output.put_line(a_text);
  end;
begin
  p('declare l_date date := sysdate; begin loop exit when l_date < sysdate; end loop; end;');
  p('/');
  for i in 1 .. cardinality(l_run_params.call_params) loop
    p('set termout '||l_run_params.call_params(i).output_to_screen);
    l_need_spool := (l_run_params.call_params(i).output_file_name is not null);
    p(case when l_need_spool then 'spool '||l_run_params.call_params(i).output_file_name||chr(10) end||
      'select * from table( '||l_output_type||'().get_lines('''||l_run_params.call_params(i).output_id||''') );'||
      case when l_need_spool then chr(10)||'spool off' end);
  end loop;
end;
/

spool off

set define #
--try running on windows
$ start sqlplus ##1/##2@##3 @run_in_backgroung.sql
--try running on linus/unix
! sqlplus ##1/##2@##3 @run_in_backgroung.sql &
set define &

--make sure we fetch row by row to indicate the progress
set arraysize 1
@gather_data_from_outputs.sql

exit
