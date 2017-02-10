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
@@helpers/department1.tps
@@helpers/test_package_3.pck
@@helpers/test_package_1.pck
@@helpers/test_package_2.pck

--Start coverage in develop mode (coverage for utPLSQL framework)
--Regular coverage excludes the framework
exec ut_coverage.coverage_start_develop();

@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParseAnnotationMixedWithWrongBeforeProcedure.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParseAnnotationNotBeforeProcedure.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParseComplexPackage.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageAndProcedureLevelAnnotations.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotation.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotationAccessibleBy.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotationMultilineDeclare.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotationWithKeyValue.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotationWithMultilineComment.sql

@@ut_expectations/ut.expect.to_be_between.GivesFailureForDifferentValues.sql
@@ut_expectations/ut.expect.to_be_between.GivesFailureWhenActualIsNull.sql
@@ut_expectations/ut.expect.to_be_between.GivesFailureWhenBothActualAndExpectedRangeIsNull.sql
@@ut_expectations/ut.expect.to_be_between.GivesFailureWhenExpectedRangeIsNull.sql
@@ut_expectations/ut.expect.to_be_between.GivesSuccessWhenDifferentTypes.sql
@@ut_expectations/ut.expect.to_be_between.GivesTrueForCorrectValues.sql
@@ut_expectations/ut.expect.to_be_between.with_text.GivesTheProvidedTextAsMessage.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_false.GivesFailureWhenExpessionIsNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_false.GivesFailureWhenExpessionIsTrue.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_false.GivesSuccessWhenExpessionIsFalse.sql
@@ut_expectations/ut.expect.to_be_like.sql
@@ut_expectations/ut.expect.to_be_not_null.GivesFailureWhenActualIsNull.sql
@@ut_expectations/ut.expect.to_be_not_null.GivesSuccessWhenActualIsNotNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_null.anydata.GivesSuccessWhenAnydataIsNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_null.anydata.GivesSuccessWhenObjectPassedIsNull.sql
@@ut_expectations/ut.expect.to_be_null.GivesFailureWhenActualIsNotNull.sql
@@ut_expectations/ut.expect.to_be_null.GivesSuccessWhenActualIsNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_null.refcursor.GivesSuccessWhenCursorIsNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_true.GivesFailureWhenExpessionIsFalse.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_true.GivesFailureWhenExpessionIsNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_true.GivesSuccessWhenExpessionIsTrue.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesFailureWhenBothObjectsAreNullButDifferentType.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesFailureWhenComparingDifferentData.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesFailureWhenOneOfObjectsIsNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesSuccessWhenBothAnydataAreNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesSuccessWhenBothObjectsAreNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesSuccessWhenComparingTheSameData.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.PutsObjectStrucureIntoAssert.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.cursor.GivesFailureForDifferentValues.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.cursor.GivesSuccessForEqualValues.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.cursor.ReturnsCursorDataForFailure.sql
@@ut_expectations/ut.expect.to_equal.GivesFailureForDifferentDataTypes.sql
@@ut_expectations/ut.expect.to_equal.GivesFailureForDifferentValues.sql
@@ut_expectations/ut.expect.to_equal.GivesFailureWhenActualIsNull.sql
@@ut_expectations/ut.expect.to_equal.GivesFailureWhenBothValuesAreNullAndArgumentAreNullEqualIsFalse.sql
@@ut_expectations/ut.expect.to_equal.GivesFailureWhenBothValuesAreNullAndConfigurationAreNullEqualIsFalse.sql
@@ut_expectations/ut.expect.to_equal.GivesFailureWhenExpectedIsNull.sql
@@ut_expectations/ut.expect.to_equal.GivesSuccessForEqualValues.sql
@@ut_expectations/ut.expect.to_equal.GivesSuccessWhenBothValuesAreNull.sql
@@ut_expectations/ut.expect.to_equal.GivesSuccessWhenBothValuesAreNullAndArgumentAreNullEqualIsTrue.sql
@@ut_expectations/ut.expect.to_equal.PutsNullIntoStringValueWhenActualIsNull.sql
@@ut_expectations/ut.expect.to_equal.PutsNullIntoStringValueWhenExpectedIsNull.sql
@@ut_expectations/ut.expect.to_equal.with_text.GivesTheProvidedTextAsMessage.sql
@@ut_expectations/ut.expect.to_match.sql
@@lib/RunTest.sql ut_expectations/ut_assert_processor.nulls_are_equal.raisesExceptionWhenTryingToSetNullValue.sql

@@ut_matchers/be_between.sql
@@ut_matchers/greater_or_equal.sql
@@ut_matchers/greater_than.sql
@@ut_matchers/less_or_equal.sql
@@ut_matchers/less_than.sql
@@ut_matchers/be_empty.sql

@@lib/RunTest.sql ut_matchers/timestamp_between.sql
@@lib/RunTest.sql ut_matchers/timestamp_ltz_between.sql
@@lib/RunTest.sql ut_matchers/timestamp_ltz_not_between.sql
@@lib/RunTest.sql ut_matchers/timestamp_not_between.sql
@@lib/RunTest.sql ut_matchers/timestamp_tz_between.sql
@@lib/RunTest.sql ut_matchers/timestamp_tz_not_between.sql

@@lib/RunTest.sql ut_metadata/ut_metadata.form_name.TrimStandaloneProgramName.sql

@@lib/RunTest.sql ut_output_buffer/get_lines.RecievesALineFromBufferTableAndDeletes.sql
@@lib/RunTest.sql ut_output_buffer/send_line.DoesNotSendLineIfNullReporterIdGiven.sql
@@lib/RunTest.sql ut_output_buffer/send_line.DoesNotSendLineIfNullTextGiven.sql
@@lib/RunTest.sql ut_output_buffer/send_line.SendsALineIntoBufferTable.sql

@@lib/RunTest.sql ut_run/ut_run.function.WithGivenReporter.ExectutesAllInCurrentSchemaUsingReporter.sql
@@lib/RunTest.sql ut_run/ut_run.function.WithNoParams.ExecutesAllFromCurrentSchema.sql
@@lib/RunTest.sql ut_run/ut_run.function.WithPackageName.ExecutesAllFromGivenPackage.sql
--@@lib/RunTest.sql ut_run/ut_run.function.WithPackageName.ExecutesAllFromGivenPackageOnly.sql --TODO this one doesn't work at the moment
@@lib/RunTest.sql ut_run/ut_run.function.WithSchemaName.ExecutesAllFromGivenSchema.sql
@@lib/RunTest.sql ut_run/ut_run.function.WithSuitePath.ExecutesAllFromGivenPath.sql
@@lib/RunTest.sql ut_run/ut_run.WithGivenReporter.ExectutesAllInCurrentSchemaUsingReporter.sql
@@lib/RunTest.sql ut_run/ut_run.WithNoParams.ExecutesAllFromCurrentSchema.sql
@@lib/RunTest.sql ut_run/ut_run.WithPackageName.ExecutesAllFromGivenPackage.sql
--@@lib/RunTest.sql ut_run/ut_run.WithPackageName.ExecutesAllFromGivenPackageOnly.sql --TODO this one doesn't work at the moment
@@lib/RunTest.sql ut_run/ut_run.WithSchemaName.ExecutesAllFromGivenSchema.sql
@@lib/RunTest.sql ut_run/ut_run.WithSuitePath.ExecutesAllFromGivenPath.sql

@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheSchema.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTopPackageByPath.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTopPackageByPathCurUser.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTop2PackageByPath.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTop2PackageByPathCurUser.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTopPackageWithoutSubsuitesByPath.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTopPackageWithoutSubsuitesByPathCurUser.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTopPackageByName.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTopPackageByNameCurUser.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTop2PackageByName.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTop2PackageByNameCurUser.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTopPackageWithoutSubsuitesByName.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTopPackageWithoutSubsuitesByNameCurUser.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTopPackageProcedureByPath.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTopPackageProcedureByPathCurUser.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTop2PackageProcedureByPath.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.configure_execution_by_path.PrepareRunnerForTheTop2PackageProcedureByPathCurUser.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.DoesntFindTheSuiteWhenPackageSpecIsInvalid.sql

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
@@lib/RunTest.sql ut_test/ut_test.IgnoreTollbackToSavepointException.sql
@@lib/RunTest.sql ut_test/ut_test.AfterEachExecuted.sql
@@lib/RunTest.sql ut_test/ut_test.AfterEachProcedureNameInvalid.sql
@@lib/RunTest.sql ut_test/ut_test.AfterEachProcedureNameNull.sql
@@lib/RunTest.sql ut_test/ut_test.BeforeEachExecuted.sql
@@lib/RunTest.sql ut_test/ut_test.BeforeEachProcedureNameInvalid.sql
@@lib/RunTest.sql ut_test/ut_test.BeforeEachProcedureNameNull.sql
@@lib/RunTest.sql ut_test/ut_test.TestOutputGathering.sql
@@lib/RunTest.sql ut_test/ut_test.TestOutputGatheringForTeamcity.sql

@@lib/RunTest.sql ut_test_suite/ut_test_suite.ErrorsATestWhenAfterTestFails.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.ErrorsATestWhenBeforeTestFails.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.ErrorsEachTestWhenBeforeAllFails.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.ErrorsEachTestWhenBeforeEachFails.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.ErrorsEachTestWhenPackageHasInvalidBody.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.ErrorsEachTestWhenPackageHasNoBody.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.IgnoreFlagSkipSuite.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.ReportsWarningsATestWhenAfterAllFails.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.ReportsWarningsATestWhenAfterEachFails.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.Rollback_type.Auto.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.Rollback_type.AutoOnFailure.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.Rollback_type.Manual.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.Rollback_type.ManualOnFailure.sql

@@ut_utils/ut_utils.clob_to_table.sql
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


--Finally
@@lib/RunSummary

--Global cleanup
--removing objects that should not be part of coverage report
drop package ut_example_tests;
drop procedure check_annotation_parsing;
drop package ut_transaction_control;
drop table ut$test_table;
drop type department$;
drop type department1$;
drop package test_package_1;
drop package test_package_2;
drop package test_package_3;

set timing on
prompt Flushing coverage data into temp tables
exec ut_coverage.coverage_stop();

prompt Generating coverage data to reporter outputs

var reporter_id varchar2(32);
declare
  l_reporter ut_coverage_html_reporter := ut_coverage_html_reporter('utPLSQL v3 Unit Tests');
begin
  :reporter_id := l_reporter.reporter_id;
  l_reporter.after_calling_run(ut_run(ut_suite_items()));
end;
/

prompt Spooling outcomes to coverage.html
set termout off
set feedback off
set arraysize 50
spool coverage.html
--getting data by putting into dbms_output
  exec ut_output_buffer.lines_to_dbms_output(:reporter_id);

--getting data by select statement
  --select * from table( ut_output_buffer.get_lines(:reporter_id) );
spool off


--can be used by CI to check for tests status
exit :failures_count
