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



column param_list new_value param_list noprint;
/*
* Prepare script to make SQLPlus parameters optional and pass parameters call to param_list variable
*/
set define off
spool define_params_variable.sql.tmp
declare
  l_sql_columns varchar2(4000);
  l_params      varchar2(4000);
begin
  for i in 1 .. 100 loop
    dbms_output.put_line('column '||i||' new_value '||i);
    l_sql_columns := l_sql_columns ||'null as "'||i||'",';
    l_params := l_params || '''''&&'||i||''''',';
  end loop;
  dbms_output.put_line('select '||rtrim(l_sql_columns, ',') ||' from dual where rownum = 0;');
  dbms_output.put_line('select '''||rtrim(l_params, ',')||''' as param_list from dual;' );
end;
/
spool off
set define &

/*
* Make SQLPlus parameters optional and pass parameters call to param_list variable
*/
@@define_params_variable.sql.tmp

var l_paths          varchar2(4000);
var l_color_enabled  varchar2(5);
var l_run_params_cur refcursor;
var l_out_params_cur refcursor;
/*
* Parse parameters and returning as variables
*/
declare

  type t_call_param is record (
    ut_reporter_name   varchar2(4000) := 'ut_documentation_reporter',
    output_file_name   varchar2(4000),
    output_to_screen   varchar2(3)    := 'on',
    reporter_id        varchar2(250)
  );

  type tt_call_params is table of t_call_param;

  l_input_params ut_varchar2_list := ut_varchar2_list(&&param_list);
  l_call_params  tt_call_params;

  l_run_cursor_sql varchar2(32767);
  l_out_cursor_sql varchar2(32767);

  function parse_reporting_params(a_params ut_varchar2_list) return tt_call_params is
    l_default_call_param  t_call_param;
    l_call_params         tt_call_params := tt_call_params();
    l_force_out_to_screen boolean;
  begin
    for param in(
      with
        param_vals as(
          select regexp_substr(column_value,'-([fos])\=?(.*)',1,1,'c',1) param_type,
                 regexp_substr(column_value,'-([fos])\=(.*)',1,1,'c',2) param_value
          from table(a_params)
          where column_value is not null)
      select param_type, param_value
      from param_vals
      where param_type is not null
    ) loop
      if param.param_type = 'f' or l_call_params.last is null then
        l_call_params.extend;
        l_call_params(l_call_params.last) := l_default_call_param;
        if param.param_type = 'f' then
          l_call_params(l_call_params.last).ut_reporter_name := dbms_assert.simple_sql_name(param.param_value);
        end if;
        l_force_out_to_screen := false;
      end if;
      if param.param_type = 'o' then
        l_call_params(l_call_params.last).output_file_name := param.param_value;
        if not l_force_out_to_screen then
          l_call_params(l_call_params.last).output_to_screen := 'off';
        end if;
      elsif param.param_type = 's' then
        l_call_params(l_call_params.last).output_to_screen := 'on';
        l_force_out_to_screen := true;
      end if;
    end loop;
    if l_call_params.count = 0 then
      l_call_params.extend;
      l_call_params(1) := l_default_call_param;
    end if;
    for i in 1 .. cardinality(l_call_params) loop
      l_call_params(i).reporter_id := sys_guid();
    end loop;
    return l_call_params;
  end;

  function parse_paths_param(a_params ut_varchar2_list) return varchar2 is
    l_paths varchar2(4000);
  begin
    begin
      select ''''||replace(ut_paths,',',''',''')||''''
        into l_paths
        from (select regexp_substr(column_value,'-p\=(.*)',1,1,'c',1) as ut_paths from table(a_params) )
       where ut_paths is not null;
    exception
      when no_data_found then
        l_paths := 'user';
      when too_many_rows then
        raise_application_error(-20000, 'Parameter "-p=ut_path(s)" defined more than once. Only one "-p=ut_path(s)" parameter can be used.');
    end;
    return l_paths;
  end;

  function parse_color_enabled(a_params ut_varchar2_list) return varchar2 is
  begin
    for i in 1 .. cardinality(a_params) loop
      if a_params(i) = '-c' then
        return 'true';
      end if;
    end loop;
    return 'false';
  end;

begin
  l_call_params := parse_reporting_params(l_input_params);
  for i in l_call_params.first .. l_call_params.last loop
    l_run_cursor_sql :=
      l_run_cursor_sql ||
      'select '''||l_call_params(i).reporter_id||''' as reporter_id,' ||
      ' '''||l_call_params(i).ut_reporter_name||''' as reporter_name' ||
      ' from dual';
    l_out_cursor_sql :=
      l_out_cursor_sql ||
      'select '''||l_call_params(i).reporter_id||''' as reporter_id,' ||
      ' '''||l_call_params(i).output_to_screen||''' as output_to_screen,' ||
      ' '''||l_call_params(i).output_file_name||''' as output_file_name' ||
      ' from dual';
    if i < l_call_params.last then
      l_run_cursor_sql := l_run_cursor_sql || ' union all ';
      l_out_cursor_sql := l_out_cursor_sql || ' union all ';
    end if;
  end loop;

  :l_paths := parse_paths_param(l_input_params);
  :l_color_enabled := parse_color_enabled(l_input_params);

  if l_run_cursor_sql is not null then
    open :l_run_params_cur for l_run_cursor_sql;
  end if;
  if l_out_cursor_sql is not null then
    open :l_out_params_cur for l_out_cursor_sql;
  end if;
end;
/


/*
* Generate runner script
*/
spool run_in_backgroung.sql.tmp
declare
  l_reporter_id   varchar2(250);
  l_reporter_name varchar2(250);
  procedure p(a_text varchar2) is begin dbms_output.put_line(a_text); end;
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
  if :l_run_params_cur%isopen then
    loop
      fetch :l_run_params_cur into l_reporter_id, l_reporter_name;
      exit when :l_run_params_cur%notfound;
        p('  v_reporter := '||l_reporter_name||'();');
        p('  v_reporter.reporter_id := '''||l_reporter_id||''';');
        p('  v_reporters_list.extend; v_reporters_list(v_reporters_list.last) := v_reporter;');
    end loop;
  end if;
  close :l_run_params_cur;
  p(  '  ut_runner.run( ut_varchar2_list('||:l_paths||'), v_reporters_list, a_color_console => '||:l_color_enabled||' );');
  p(  'end;');
  p(  '/');
  p(  'spool off');
  p(  'exit');
end;
/
spool off

/*
* Generate output retrieval script
*/
spool gather_data_from_outputs.sql.tmp
declare
  l_reporter_id      varchar2(250);
  l_output_file_name varchar2(250);
  l_output_to_screen varchar2(250);
  l_need_spool  boolean;
  procedure p(a_text varchar2) is begin dbms_output.put_line(a_text); end;
begin
  if :l_out_params_cur%isopen then
    loop
      fetch :l_out_params_cur into l_reporter_id, l_output_to_screen, l_output_file_name;
      exit when :l_out_params_cur%notfound;
      l_need_spool := (l_output_file_name is not null);
      p(   'set termout '||l_output_to_screen);
      if l_need_spool then
        p( 'spool '||l_output_file_name);
      end if;
      p(   'select * from table( ut_output_buffer.get_lines('''||l_reporter_id||''') );');
      if l_need_spool then
        p('spool off');
      end if;
    end loop;
  end if;
end;
/
spool off


/*
* Execute runner script in background process
*/
set define #
--try running on windows
$ start sqlplus ##1 @run_in_backgroung.sql.tmp
--try running on linus/unix
! sqlplus ##1 @run_in_backgroung.sql.tmp &
set define &
set termout on


--make sure we fetch row by row to indicate the progress
set arraysize 1
/*
* Gather outputs from reporters one by one while runner script executes.
*/
@gather_data_from_outputs.sql.tmp

set termout off
/*
* cleanup temporary sql files
*/
--try running on windows
$ del *.sql.tmp
--try running on linus/unix
! rm *.sql.tmp

exit
