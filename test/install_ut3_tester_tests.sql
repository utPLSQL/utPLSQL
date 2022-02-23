set define off
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

alter session set plsql_optimize_level=0;

@@common_helper/utplsql.pks
@@common_helper/utplsql.pkb

--Install tests
@@ut3_tester/core.pks
@@ut3_tester/core/annotations/test_before_after_annotations.pks
@@ut3_tester/core/annotations/test_annotation_parser.pks
@@ut3_tester/core/annotations/test_annot_throws_exception.pks
@@ut3_tester/core/annotations/test_annotation_manager.pks
@@ut3_tester/core/annotations/test_annotation_cache.pks
@@ut3_tester/core/annotations/test_annot_disabled_reason.pks
@@ut3_tester/core/expectations/test_expectation_processor.pks
@@ut3_tester/core/test_ut_utils.pks
@@ut3_tester/core/test_ut_test.pks
@@ut3_tester/core/test_ut_suite.pks
@@ut3_tester/core/test_ut_executable.pks
@@ut3_tester/core/test_suite_manager.pks
@@ut3_tester/core/test_file_mapper.pks
@@ut3_tester/core/test_output_buffer.pks
@@ut3_tester/core/test_suite_builder.pks


@@ut3_tester/core.pkb
@@ut3_tester/core/annotations/test_before_after_annotations.pkb
@@ut3_tester/core/annotations/test_annotation_parser.pkb
@@ut3_tester/core/annotations/test_annotation_manager.pkb
@@ut3_tester/core/annotations/test_annot_throws_exception.pkb
@@ut3_tester/core/annotations/test_annotation_cache.pkb
@@ut3_tester/core/annotations/test_annot_disabled_reason.pkb
@@ut3_tester/core/expectations/test_expectation_processor.pkb
@@ut3_tester/core/test_ut_utils.pkb
@@ut3_tester/core/test_ut_test.pkb
@@ut3_tester/core/test_ut_suite.pkb
@@ut3_tester/core/test_ut_executable.pkb
@@ut3_tester/core/test_suite_manager.pkb
@@ut3_tester/core/test_file_mapper.pkb
@@ut3_tester/core/test_output_buffer.pkb
@@ut3_tester/core/test_suite_builder.pkb



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
   and name != 'UT_WITH_INVALID_BODY'
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

exit;
