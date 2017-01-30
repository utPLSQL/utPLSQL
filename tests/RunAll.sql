set trimspool on
set echo off
set feedback off
set verify off
Clear Screen
set linesize 32767
set pagesize 0
set long 200000000
set longchunksize 1000000
set serveroutput on size unlimited format truncated
@@lib/RunVars.sql

--Global setup
@@helpers/ut_example_tests.pks
@@helpers/ut_example_tests.pkb
@@helpers/check_annotation_parsing.prc
--@@helpers/cre_tab_ut_test_table.sql
create table ut$test_table (val varchar2(1));
@@helpers/ut_transaction_control.pck
@@helpers/department.tps
@@helpers/test_package_3.pck
@@helpers/test_package_1.pck
@@helpers/test_package_2.pck

--Start coverage in develop mode (coverage for utPLSQL framework)
--Regular coverage excludes the framework
exec ut_coverage.coverage_start_develop();

@@lib/RunTest.sql asssertions/ut.expect.to_be_false.GivesFailureWhenExpessionIsNull.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_false.GivesFailureWhenExpessionIsTrue.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_false.GivesSuccessWhenExpessionIsFalse.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_like.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_not_null.GivesFailureWhenActualIsNull.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_not_null.GivesSuccessWhenActualIsNotNull.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_null.anydata.GivesSuccessWhenAnydataIsNull.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_null.anydata.GivesSuccessWhenObjectPassedIsNull.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_null.GivesFailureWhenActualIsNotNull.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_null.GivesSuccessWhenActualIsNull.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_null.refcursor.GivesSuccessWhenCursorIsNull.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_true.GivesFailureWhenExpessionIsFalse.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_true.GivesFailureWhenExpessionIsNull.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_true.GivesSuccessWhenExpessionIsTrue.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.anydata.GivesFailureWhenComparingDifferentData.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.anydata.GivesSuccessWhenComparingTheSameData.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.anydata.PutsObjectStrucureIntoAssert.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.cursor.GivesFailureForDifferentValues.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.cursor.GivesSuccessForEqualValues.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.cursor.ReturnsCursorDataForFailure.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.GivesFailureForDifferentDataTypes.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.GivesFailureForDifferentValues.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.GivesFailureWhenActualIsNull.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.GivesFailureWhenBothValuesAreNullAndArgumentAreNullEqualIsFalse.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.GivesFailureWhenBothValuesAreNullAndConfigurationAreNullEqualIsFalse.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.GivesFailureWhenExpectedIsNull.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.GivesSuccessForEqualValues.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.GivesSuccessWhenBothValuesAreNull.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.GivesSuccessWhenBothValuesAreNullAndArgumentAreNullEqualIsTrue.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.PutsNullIntoStringValueWhenActualIsNull.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.PutsNullIntoStringValueWhenExpectedIsNull.sql
@@lib/RunTest.sql asssertions/ut.expect.to_equal.with_text.GivesTheProvidedTextAsMessage.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_between.GivesFailureForDifferentValues.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_between.GivesTrueForCorrectValues.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_between.with_text.GivesTheProvidedTextAsMessage.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_between.GivesFailureWhenActualIsNull.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_between.GivesFailureWhenBothActualAndExpectedRangeIsNull.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_between.GivesFailureWhenExpectedRangeIsNull.sql
@@lib/RunTest.sql asssertions/ut.expect.to_be_between.GivesSuccessWhenDifferentTypes.sql
@@lib/RunTest.sql asssertions/ut.expect.to_match.sql
@@lib/RunTest.sql asssertions/ut_assert_processor.nulls_are_equal.raisesExceptionWhenTryingToSetNullValue.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParseAnnotationMixedWithWrongBeforeProcedure.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParseAnnotationNotBeforeProcedure.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParseComplexPackage.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageAndProcedureLevelAnnotations.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotation.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotationAccessibleBy.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotationMultilineDeclare.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotationWithKeyValue.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotationWithMultilineComment.sql
@@lib/RunTest.sql ut_metadata/ut_metadata.form_name.TrimStandaloneProgramName.sql
@@lib/RunTest.sql ut_test/ut_test.IgnoreFlagSkipTest.sql
@@lib/RunTest.sql ut_test/ut_test.OwnerNameInvalid.sql
@@lib/RunTest.sql ut_test/ut_test.OwnerNameNull.sql
@@lib/RunTest.sql ut_test/ut_test.PackageInInvalidState.sql
@@lib/RunTest.sql ut_test/ut_test.PackageNameInvalid.sql
@@lib/RunTest.sql ut_test/ut_test.PackageNameNull.sql
@@lib/RunTest.sql ut_test/ut_test.ProcedureNameInvalid.sql
@@lib/RunTest.sql ut_test/ut_test.ProcedureNameNull.sql
@@lib/RunTest.sql ut_test/ut_test.Rollback_type.Auto.sql
@@lib/RunTest.sql ut_test/ut_test.Rollback_type.AutoOnFailure.sql
@@lib/RunTest.sql ut_test/ut_test.Rollback_type.Manual.sql
@@lib/RunTest.sql ut_test/ut_test.Rollback_type.ManualOnFailure.sql
@@lib/RunTest.sql ut_test/ut_test.SetupExecutedBeforeTest.sql
@@lib/RunTest.sql ut_test/ut_test.SetupProcedureNameInvalid.sql
@@lib/RunTest.sql ut_test/ut_test.SetupProcedureNameNull.sql
@@lib/RunTest.sql ut_test/ut_test.TeardownExecutedAfterTest.sql
@@lib/RunTest.sql ut_test/ut_test.TeardownProcedureNameInvalid.sql
@@lib/RunTest.sql ut_test/ut_test.TeardownProcedureNameNull.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.IgnoreFlagSkipSuite.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.Rollback_type.Auto.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.Rollback_type.AutoOnFailure.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.Rollback_type.Manual.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.Rollback_type.ManualOnFailure.sql
@@lib/RunTest.sql ut_utils/ut_utils.test_result_to_char.RunsWithInvalidValues.sql
@@lib/RunTest.sql ut_utils/ut_utils.test_result_to_char.RunsWithNullValue.sql
@@lib/RunTest.sql ut_utils/ut_utils.test_result_to_char.Success.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.Blob.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.Clob.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.Date.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.NullBlob.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.NullClob.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.NullDate.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.NullNumber.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.NullTimestamp.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.NullVarchar2.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.Timestamp.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.TimestampWithLocalTimeZone.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.TimestampWithTimeZone.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.Varchar2.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.veryBigBlob.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.veryBigClob.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.veryBigNumber.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.veryBigVarchar2.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.verySmallNumber.sql
@@ut_utils/ut_utils.clob_to_table.sql

@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheSchema.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTopPackageByPath.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTop2PackageByPath.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTopPackageWithoutSubsuitesByPath.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTopPackageByName.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTop2PackageByName.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTopPackageWithoutSubsuitesByName.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTopPackageProcedureByPath.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTop2PackageProcedureByPath.sql

@@lib/RunTest.sql ut_output_dbms_pipe/ut_output_dbms_pipe.close.TimesOutAfterAGivenPeriodOfTimeAndRemovesPipe.sql
@@lib/RunTest.sql ut_output_dbms_pipe/ut_output_dbms_pipe.get_clob_lines.ReturnsSentLines.sql
@@lib/RunTest.sql ut_output_dbms_pipe/ut_output_dbms_pipe.get_lines.ReturnsSentLines.sql
@@lib/RunTest.sql ut_output_dbms_pipe/ut_output_dbms_pipe.get_lines.TimesOutAfterAGivenPeriodOfTime.sql
@@lib/RunTest.sql ut_output_dbms_pipe/ut_output_dbms_pipe.open.CreatesAPrivatePipe.sql
@@lib/RunTest.sql ut_output_dbms_pipe/ut_output_dbms_pipe.send_clob.SendsAClobIntoPipe.sql

@@lib/RunTest.sql ut_output_dbms_output/ut_output_dbms_output.get_clob_lines.ReturnsSentLines.sql
@@lib/RunTest.sql ut_output_dbms_output/ut_output_dbms_output.get_lines.RetunrsNoRowsWhenNoDataInBuffer.sql
@@lib/RunTest.sql ut_output_dbms_output/ut_output_dbms_output.get_lines.ReturnsSentLines.sql
@@lib/RunTest.sql ut_output_dbms_output/ut_output_dbms_output.send_clob.SendsAClobIntoPipe.sql

@@lib/RunTest.sql ut_expectations/greater_or_equal.sql
@@lib/RunTest.sql ut_expectations/greater_than.sql
@@lib/RunTest.sql ut_expectations/less_or_equal.sql
@@lib/RunTest.sql ut_expectations/less_than.sql
@@lib/RunTest.sql ut_expectations/be_between.sql
@@lib/RunTest.sql ut_expectations/timestamp_between.sql
@@lib/RunTest.sql ut_expectations/timestamp_ltz_between.sql
@@lib/RunTest.sql ut_expectations/timestamp_ltz_not_between.sql
@@lib/RunTest.sql ut_expectations/timestamp_not_between.sql
@@lib/RunTest.sql ut_expectations/timestamp_tz_between.sql
@@lib/RunTest.sql ut_expectations/timestamp_tz_not_between.sql

--Finally
@@lib/RunSummary

exec ut_coverage.coverage_stop();

set define off
--remove previous coverage run data
--try running on windows
--$ rmdir /s /q coverage & mkdir coverage & mkdir coverage\assets & xcopy /E lib\coverage\assets coverage\assets\
$ rmdir /s /q coverage  > nul 2>&1 & mkdir coverage  > nul 2>&1 & xcopy /E ..\client_source\sqlplus\lib\coverage\assets coverage\assets\  > nul 2>&1 & xcopy /E ..\client_source\sqlplus\lib\coverage\public coverage\assets\  > nul 2>&1
--try running on linus/unix
! rm -rf coverage ; mkdir coverage ; cp -R ../client_source/sqlplus/lib/coverage/assets coverage/assets ; cp -R ../client_source/sqlplus/lib/coverage/public coverage/assets

set define &
begin
  ut_coverage_report_html_helper.init(ut_coverage.get_coverage_data());
end;
/

set termout off
set feedback off
spool coverage/index.html
  select ut_coverage_report_html_helper.get_index() from dual;
spool off

--Global cleanup
drop package ut_example_tests;
drop procedure check_annotation_parsing;
drop package ut_transaction_control;
drop table ut$test_table;
drop type department$;
drop package test_package_1;
drop package test_package_2;
drop package test_package_3;

--Finally
@@lib/RunSummary
--can be used by CI to check for tests status
exit :failures_count
