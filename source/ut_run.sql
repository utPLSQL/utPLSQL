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

def output_stream_type = 'ut_output_dbms_pipe()';
var v_output_ids_cur refcursor;
var v_output_id varchar2(4000);

whenever sqlerror exit failure
whenever oserror exit failure
conn &1/&2@&3
whenever sqlerror continue
whenever oserror continue

set serveroutput on size unlimited format truncated
set trimspool on
set echo off
set feedback off
set pagesize 0
set linesize 30000
set long 30000
set longchunksize 30000
set verify off
set heading off
column  1 new_value  1
column  2 new_value  2
column  3 new_value  3
column  4 new_value  4
column  5 new_value  5
column  6 new_value  6
column  7 new_value  7
column  8 new_value  8
column  9 new_value  9
column 10 new_value 10
column 11 new_value 11
column 12 new_value 12
column 13 new_value 13
column 14 new_value 14
column 15 new_value 15
column 16 new_value 16
column 17 new_value 17
column 18 new_value 18
column 19 new_value 19
column 20 new_value 20
column 21 new_value 21
column 22 new_value 22
column 23 new_value 23
column 24 new_value 24
column 25 new_value 25
column 26 new_value 26
column 27 new_value 27
column 28 new_value 28
column 29 new_value 29
column 30 new_value 30
column 31 new_value 31
column 32 new_value 32
column 33 new_value 33
column 34 new_value 34
column 35 new_value 35
column 36 new_value 36
column 37 new_value 37
column 38 new_value 38
column 39 new_value 39
select '' "1",'' "2",'' "3",'' "4",'' "5",'' "6",'' "7",'' "8",'' "9",
       '' "10",'' "11",'' "12",'' "13",'' "14",'' "15",'' "16",'' "17",'' "18",'' "19",
       '' "20",'' "21",'' "22",'' "23",'' "24",'' "25",'' "26",'' "27",'' "28",'' "29",
       '' "30",'' "31",'' "32",'' "33",'' "34",'' "35",'' "36",'' "37",'' "38",'' "39"
from dual where rownum = 0;


def usr_name='&&1'
def usr_pass='&&2'
def usr_db='&&3'
def ut_paths='&&4'
-- var run_in_background_script varchar2(4000);
-- var get_outputs_script       varchar2(4000);
var run_in_background_script clob;
var get_outputs_script       clob;

declare
  c_output              constant ut_output := &&output_stream_type;
  c_out_script_template constant varchar2(400) := '
exec dbms_output.put_line(:v_output_id);
set termout {output_to_screen}
exec fetch :v_output_ids_cur into :v_output_id;
spool {l_spool_output}
  select * from table( ut_output_dbms_pipe().get_lines(:v_output_id,30) );
spool off
';
  l_ut_paths           varchar2(32767);
  l_background_script  varchar2(32767);
  l_output_script_part varchar2(32767);
  l_outputs_script     varchar2(32767);
  l_output_id          varchar2(128);
  l_output_ids         ut_varchar2_list := ut_varchar2_list();
begin
  if not regexp_like('&&ut_paths','-([fos])\=?(.*)') then
    --add quotes around each path
    l_ut_paths := ''''||replace('&&ut_paths',',',''',''')||'''';
  else
    l_ut_paths := 'user';
  end if;
  l_background_script :=
    'conn &&usr_name/&&usr_pass@&&usr_db'||chr(10)||
    'set serveroutput on size unlimited format truncated'||chr(10)||
    'set pagesize 0'||chr(10)||
    'set linesize 4000'||chr(10)||
    'spool run_background.log'||chr(10)||
    'declare'||chr(10)||
    '  v_reporter       ut_reporter;'||chr(10)||
    '  v_reporters_list ut_reporters_list := ut_reporters_list();'||chr(10)||
    'begin';
  for param in (
    with
      params as (
        select '&&4'  as param from dual union all
        select '&&5'  as param from dual union all
        select '&&6'  as param from dual union all
        select '&&7'  as param from dual union all
        select '&&8'  as param from dual union all
        select '&&9'  as param from dual union all
        select '&&10' as param from dual union all
        select '&&11' as param from dual union all
        select '&&12' as param from dual union all
        select '&&13' as param from dual union all
        select '&&14' as param from dual union all
        select '&&15' as param from dual union all
        select '&&16' as param from dual union all
        select '&&17' as param from dual union all
        select '&&18' as param from dual union all
        select '&&19' as param from dual union all
        select '&&20' as param from dual union all
        select '&&21' as param from dual union all
        select '&&22' as param from dual union all
        select '&&23' as param from dual union all
        select '&&24' as param from dual union all
        select '&&25' as param from dual union all
        select '&&26' as param from dual union all
        select '&&27' as param from dual union all
        select '&&28' as param from dual union all
        select '&&29' as param from dual union all
        select '&&30' as param from dual union all
        select '&&31' as param from dual union all
        select '&&32' as param from dual union all
        select '&&33' as param from dual union all
        select '&&34' as param from dual union all
        select '&&35' as param from dual union all
        select '&&36' as param from dual union all
        select '&&37' as param from dual union all
        select '&&38' as param from dual union all
        select '&&39' as param from dual
      ),
      param_vals as(
        select regexp_substr(param,'-([fos])\=?(.*)',1,1,'c',1) param_type,
               regexp_substr(param,'-([fos])\=(.*)',1,1,'c',2) param_value
          from params
         where param is not null)
    select param_type, param_value
      from param_vals
     where param_type is not null)
  loop
    if param.param_type = 'f' then
      l_outputs_script :=
        l_outputs_script ||
        replace(replace(l_output_script_part,'{output_to_screen}','off'),'{l_spool_output}','off');

      l_output_id := c_output.generate_output_id();
      l_background_script := l_background_script ||chr(10)||
        '  v_reporter := '||param.param_value||'('||c_output.output_type||'());'||chr(10)||
        '  v_reporter.output.output_id := '''||l_output_id||''';'||chr(10)||
        '  v_reporters_list.extend; v_reporters_list(v_reporters_list.last) := v_reporter;';
      l_output_ids.extend;
      l_output_ids(l_output_ids.last) := l_output_id;

      l_output_script_part := c_out_script_template;
    elsif param.param_type = 'o' then
      l_output_script_part := replace(l_output_script_part,'{l_spool_output}',param.param_value);
    elsif param.param_type = 's' then
      l_output_script_part := replace(l_output_script_part,'{output_to_screen}','on');
    end if;
  end loop;
   l_outputs_script :=
     l_outputs_script ||
     replace(replace(l_output_script_part,'{output_to_screen}','off'),'{l_spool_output}','off');
  l_background_script := l_background_script||chr(10)||
    '  ut.run( ut_varchar2_list('||l_ut_paths||'), ut_composite_reporter( v_reporters_list ) );'||chr(10)||
    'end;'||chr(10)||
    '/'||chr(10)||
    'exit';
  :run_in_background_script := l_background_script;
  :get_outputs_script       := l_outputs_script;
  open :v_output_ids_cur for select * from table(l_output_ids);
end;
/
set termout off
spool ut_run_in_background.sql
  select :run_in_background_script from dual;
spool off

spool ut_get_outputs.sql
  select :get_outputs_script from dual;
spool off

set define #
--try running on windows
$ start sqlplus /nolog @ut_run_in_background.sql
--try running on linus/unix
! sqlplus /nolog @run_background.sql &
set define &

--make sure we fetch row by row to indicate the progress
set arraysize 1
@@ut_get_outputs.sql

exec close :v_output_ids_cur;

exit