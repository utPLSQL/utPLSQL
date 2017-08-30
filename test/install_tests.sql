whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

@core.pks
@ut_utils/test_ut_utils.pks
@ut_annotations/test_annotations.pks
@ut_matchers/test_matchers.pks
@ut_output_buffer/test_output_buffer.pks
@ut_suite_manager/test_suite_manager.pks
@@ut_reporters/test_coverage.pks
@@ut_reporters/test_coverage_sonar_reporter.pks
@@ut_reporters/test_coveralls_reporter.pks
@ut_expectations/test_expectations_cursor.pks
@@ut_runner/test_ut_runner.pks

@core.pkb
@ut_utils/test_ut_utils.pkb
@ut_annotations/test_annotations.pkb
@ut_matchers/test_matchers.pkb
@ut_output_buffer/test_output_buffer.pkb
@ut_suite_manager/test_suite_manager.pkb
@@ut_reporters/test_coverage.pkb
@@ut_reporters/test_coverage_sonar_reporter.pkb
@@ut_reporters/test_coveralls_reporter.pkb
@ut_expectations/test_expectations_cursor.pkb
@@ut_runner/test_ut_runner.pkb

set linesize 200
set define on
set verify off
column text format a100
column error_count noprint new_value error_count

prompt Validating installation

set heading on
select type, name, sequence, line, position, text, count(1) over() error_count
  from all_errors
 where owner = USER
   and name not like 'BIN$%'  --not recycled
   -- errors only. ignore warnings
   and attribute = 'ERROR'
 order by name, type, sequence
/

begin
  if to_number('&&error_count') > 0 then
    raise_application_error(-20000, 'Not all sources were successfully installed.');
  else
    dbms_output.put_line('Installation completed successfully');
  end if;
end;
/

exit
