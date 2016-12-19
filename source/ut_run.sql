/**
  This script is designed to allow invocation of UTPLSQL with multiple reporters.
  It allows saving of outcomes into multiple output files.
  It also facilitates displaying on screen unit test results while the execution is still ongoing.
  Current limit of script parameters is 39

Scrip invocation:
  ut_run.sql user password database -p=ut_paths (-f=format [-o=output] [-s] ...)

Parameters:
  user     - username to connect as
  password - password of the user
  database - database to connect to
  -p=ut_paths - a comma separated list of ut_path (with no spaces in between) of unit tests to be executed: user[.package[.procedure]]
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
set feedback off
set pagesize 0
set linesize 30000
set long 30000
set longchunksize 30000
set verify off
set heading off
set termout off

spool optional_params_script.sql
select * from table(ut_runner.get_optional_params_script());
spool off

@@optional_params_script.sql

spool run_in_backgroung.sql
select * from table(ut_runner.get_run_in_background_script());
spool off

spool gather_data_from_outputs.sql
select * from table(ut_runner.get_outputs_script());
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