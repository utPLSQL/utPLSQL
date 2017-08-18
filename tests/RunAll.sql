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

@@lib/mystats/mystats_pkg.sql
exec mystats_pkg.ms_start;

spool RunAll.log

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
@@helpers/utplsql_test_reporter.typ
@@helpers/test_reporters.pks
@@helpers/test_reporters.pkb
@@helpers/html_coverage_test.pck
@@helpers/test_reporters_1.pks
@@helpers/test_reporters_1.pkb

--Start coverage in develop mode (coverage for utPLSQL framework)
--Regular coverage excludes the framework
exec ut_coverage.coverage_start_develop();

@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.IgnoreWrappedPackageAndDoesNotRaiseException.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParseAnnotationMixedWithWrongBeforeProcedure.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParseAnnotationNotBeforeProcedure.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParseAnnotationParamsWithBrackets.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageAndProcedureLevelAnnotations.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotation.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotationAccessibleBy.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotationMultilineDeclare.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotationWithKeyValue.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotationWithMultilineComment.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.spaceBeforeAnnotationParams.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParseAnnotationWithWindowsNewline.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParseProcedureAnnotationWithVeryLongName.sql
@@lib/RunTest.sql ut_expectation_processor/who_called_expectation.parseStackTrace.sql
@@lib/RunTest.sql ut_expectation_processor/who_called_expectation.parseStackTraceWith0x.sql
@@lib/RunTest.sql ut_expectations/ut.expect.not_to_equal.anydata.GivesFailureWhenComparingTheSameData.sql
@@ut_expectations/ut.expect.not_to_be_null.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_false.GivesFailureWhenExpessionIsNotBoolean.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_false.GivesFailureWhenExpessionIsNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_false.GivesFailureWhenExpessionIsTrue.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_false.GivesSuccessWhenExpessionIsFalse.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_like.FailsForUnsupportedDatatype.sql
@@ut_expectations/ut.expect.to_be_not_null.GivesFailureWhenActualIsNull.sql
@@ut_expectations/ut.expect.to_be_not_null.GivesSuccessWhenActualIsNotNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_null.anydata.GivesSuccessWhenAnydataIsNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_null.anydata.GivesSuccessWhenCollectionPassedIsNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_null.anydata.GivesSuccessWhenObjectPassedIsNull.sql
@@ut_expectations/ut.expect.to_be_null.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_null.refcursor.GivesSuccessWhenCursorIsNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_true.GivesFailureWhenExpessionIsFalse.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_true.GivesFailureWhenExpessionIsNotBoolean.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_true.GivesFailureWhenExpessionIsNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_be_true.GivesSuccessWhenExpessionIsTrue.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.ExcludeColumnsXPathFailsOnInvalidXPath.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesFailureWhenBothObjectsAreNullButDifferentType.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesFailureWhenComparingDifferentData.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesFailureWhenComparingDifferentObjects.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesFailureWhenComparingObejctToCollection.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesFailureWhenOneOfObjectsIsNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesSuccessWhenBothAnydataAreNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesSuccessWhenBothObjectsAreNull.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesSuccessWhenComparingTheSameCollections.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesSuccessWhenComparingTheSameData.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.PutsObjectStrucureIntoResult.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesSuccessWithExcludedCollectionAttributes.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesSuccessWithExcludedCollectionAttributesXPath.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesSuccessWithExcludedObjectAttributes.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.anydata.GivesSuccessWithExcludedObjectAttributesXPath.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.cursor.ComparesDateAndTimeWhenSetNlsIsUsed.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.cursor.ExcludeColumnNameListIsCaseSensitive.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.cursor.ExcludeColumnNamesAreCaseSensitive.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.cursor.ExcludeColumnsXPathFailsOnInvalidXPath.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.cursor.ExcludeColumnsXPathIsCaseSensitive.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.cursor.GivesFailureForDifferentValues.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.cursor.GivesSuccessForEqualValues.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.cursor.GivesSuccessForEqualValuesWithExcludedColumnList.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.cursor.GivesSuccessForEqualValuesWithExcludedColumns.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.cursor.ReportsTheExceptionWhenAnExceptionInCursorIsCaught.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.cursor.ReturnsCursorDataForFailure.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.cursor.SupportsSQLandPLSQLdatatypes.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.cursor.UsesDefaultNLSSettingsForDatesFormatting.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_equal.cursor.worksOnLargeDatasets.sql
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
@@ut_expectations/ut.expect.not_to_equal.GivesFailureForDifferentDataTypes.sql
@@ut_expectations/ut.expect.not_to_equal.GivesFailureForEqualValues.sql
@@ut_expectations/ut.expect.not_to_equal.GivesSuccessForDifferentValues.sql
@@lib/RunTest.sql ut_expectations/ut.expect.to_match.FailsForUnsupportedDatatype.sql
@@lib/RunTest.sql ut_expectations/ut_data_value_object.compare.Gives0WhenComparingIdenticalObjects.sql
@@lib/RunTest.sql ut_expectations/ut_expectation_processor.nulls_are_equal.raisesExceptionWhenTryingToSetNullValue.sql
@@lib/RunTest.sql ut_expectations/ut_expectation_processor.stackOnFailedTest.sql
@@lib/RunTest.sql ut_expectations/ut_expectation_processor.stackOnUtFail.sql

@@ut_matchers/be_between.sql
@@ut_matchers/be_empty.sql
@@ut_matchers/be_like.sql
@@ut_matchers/greater_or_equal.sql
@@ut_matchers/greater_than.sql
@@ut_matchers/less_or_equal.sql
@@ut_matchers/less_than.sql
@@ut_matchers/match.sql

@@lib/RunTest.sql ut_matchers/timestamp_between.sql
@@lib/RunTest.sql ut_matchers/timestamp_ltz_between.sql
@@lib/RunTest.sql ut_matchers/timestamp_ltz_not_between.sql
@@lib/RunTest.sql ut_matchers/timestamp_not_between.sql
@@lib/RunTest.sql ut_matchers/timestamp_tz_between.sql
@@lib/RunTest.sql ut_matchers/timestamp_tz_not_between.sql

@@lib/RunTest.sql ut_metadata/ut_metadata.form_name.TrimStandaloneProgramName.sql

@@lib/RunTest.sql ut_output_buffer/get_lines.RecievesALineFromBufferTableAndDeletes.sql
@@lib/RunTest.sql ut_output_buffer/get_lines.WaitsForMoreDataToAppearForSpecifiedTime.sql
@@lib/RunTest.sql ut_output_buffer/get_lines.WaitsForTheDataToAppearForSpecifiedTime.sql
@@lib/RunTest.sql ut_output_buffer/send_line.DoesNotSendLineIfNullTextGiven.sql
@@lib/RunTest.sql ut_output_buffer/send_line.SendsALineIntoBufferTable.sql

@@lib/RunTest.sql ut_reporters/ut_coverage_sonar_reporter.AcceptsFileMapping.sql
@@lib/RunTest.sql ut_reporters/ut_coverage_sonar_reporter.BuildsSonarCoverageReport.sql
@@lib/RunTest.sql ut_reporters/ut_documentation_reporter.providesCorrectLineFromStacktrace.sql
@@lib/RunTest.sql ut_reporters/ut_sonar_test_reporter.AcceptsFileMapping.sql
@@lib/RunTest.sql ut_reporters/ut_sonar_test_reporter.ProducesExpectedOutputs.sql
@@lib/RunTest.sql ut_reporters/ut_teamcity_reporter.ProducesExpectedOutputs.sql
@@lib/RunTest.sql ut_reporters/ut_xunit_reporter.ProducesExpectedOutputs.sql
@@lib/RunTest.sql ut_reporters/ut_html_reporter.UserOverrideSchemaCoverage.sql
@@lib/RunTest.sql ut_reporters/ut_html_reporter.DefaultSchemaCoverage.sql
@@lib/RunTest.sql ut_reporters/ut_documentation_reporter.reportMultipleWarnings.sql
@@lib/RunTest.sql ut_reporters/ut_xunit_reporter.ReportOnSuiteWithoutDesc.sql
@@lib/RunTest.sql ut_reporters/ut_xunit_reporter.ReportOnTestWithoutDesc.sql
@@lib/RunTest.sql ut_reporters/ut_documentation_reporter.reportTestTiming.sql

@@lib/RunTest.sql ut/ut.run.AcceptsCoverageFileList.sql
@@lib/RunTest.sql ut/ut.run.AcceptsCoverageFileListWithSutePaths.sql
@@lib/RunTest.sql ut/ut.run.AcceptsSutePaths.sql
@@lib/RunTest.sql ut/ut.run.ExecutesSuccesfullyAnEmptySuite.sql
@@lib/RunTest.sql ut/ut.run.FailsToExecuteAnInvalidPackageBody.sql
@@lib/RunTest.sql ut/ut.run.function.AcceptsCoverageFileList.sql
@@lib/RunTest.sql ut/ut.run.function.AcceptsCoverageFileListWithSutePaths.sql
@@lib/RunTest.sql ut/ut.run.function.AcceptsSutePaths.sql
@@lib/RunTest.sql ut/ut.run.function.WithGivenReporter.ExectutesAllInCurrentSchemaUsingReporter.sql
@@lib/RunTest.sql ut/ut.run.function.WithNoParams.ExecutesAllFromCurrentSchema.sql
@@lib/RunTest.sql ut/ut.run.function.WithPackageName.ExecutesAllFromGivenPackage.sql
--@@lib/RunTest.sql ut.run/ut.run.function.WithPackageName.ExecutesAllFromGivenPackageOnly.sql --TODO this one doesn't work at the moment
@@lib/RunTest.sql ut/ut.run.function.WithSchemaName.ExecutesAllFromGivenSchema.sql
@@lib/RunTest.sql ut/ut.run.function.WithSuitePath.ExecutesAllFromGivenPath.sql
@@lib/RunTest.sql ut/ut.run.WithGivenReporter.ExectutesAllInCurrentSchemaUsingReporter.sql
@@lib/RunTest.sql ut/ut.run.WithNoParams.ExecutesAllFromCurrentSchema.sql
@@lib/RunTest.sql ut/ut.run.WithPackageName.ExecutesAllFromGivenPackage.sql
--@@lib/RunTest.sql ut.run/ut.run.WithPackageName.ExecutesAllFromGivenPackageOnly.sql --TODO this one doesn't work at the moment
@@lib/RunTest.sql ut/ut.run.WithSchemaName.ExecutesAllFromGivenSchema.sql
@@lib/RunTest.sql ut/ut.run.WithSuitePath.ExecutesAllFromGivenPath.sql
@@lib/RunTest.sql ut/ut.version.sql

@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.AllowsDescriptionsWithComma.sql
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
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.emptySuitePath.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.get_schema_ut_packages.IncludesPackagesWithSutePath.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.IncludesInvalidPackageBodiesInTheRun.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.CacheInvalidaesOnPackageDrop.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.PackageWithDollarSign.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.PackageWithHash.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.TestWithDollarSign.sql
@@lib/RunTest.sql ut_suite_manager/ut_suite_manager.TestWithHashSign.sql


@@lib/RunTest.sql ut_test/ut_test.DisabledFlagSkipTest.sql
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
@@lib/RunTest.sql ut_test/ut_test.TestOutputGatheringWhenEmpty.sql
@@lib/RunTest.sql ut_test/ut_test.ReportWarningOnRollbackFailed.sql
@@lib/RunTest.sql ut_test/ut_test.ApplicationInfoOnExecution.sql

@@lib/RunTest.sql ut_test_suite/ut_test_suite.ErrorsATestWhenAfterTestFails.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.ErrorsATestWhenBeforeTestFails.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.ErrorsEachTestWhenBeforeAllFails.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.ErrorsEachTestWhenBeforeEachFails.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.ErrorsEachTestWhenPackageHasInvalidBody.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.ErrorsEachTestWhenPackageHasNoBody.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.DisabledFlagSkipSuite.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.ReportsWarningsATestWhenAfterAllFails.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.ReportsWarningsATestWhenAfterEachFails.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.Rollback_type.Auto.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.Rollback_type.AutoOnFailure.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.Rollback_type.Manual.sql
@@lib/RunTest.sql ut_test_suite/ut_test_suite.Rollback_type.ManualOnFailure.sql

@@ut_utils/ut_utils.clob_to_table.sql
@@ut_utils/ut_utils.table_to_clob.sql
@@lib/RunTest.sql ut_utils/ut_utils.append_to_clob.worksWithMultiByteChars.sql
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

spool off

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
drop type utplsql_test_reporter;
drop package test_reporters;
drop package ut3$user#.html_coverage_test;

set timing on
prompt Generating coverage data to reporter outputs

var html_reporter_id varchar2(32);
var sonar_reporter_id  varchar2(32);
var coveralls_reporter_id varchar2(32);
declare
  l_reporter          ut_reporter_base;
  l_project_file_list ut_varchar2_list;
  l_test_run          ut_run;
begin
  l_project_file_list := ut_varchar2_list(
    'source/api',
    'source/core',
    'source/create_synonyms_and_grants_for_public.sql',
    'source/create_synonyms_and_grants_for_user.sql',
    'source/create_utplsql_owner.sql',
    'source/define_ut3_owner_param.sql',
    'source/expectations',
    'source/install.log',
    'source/install.sql',
    'source/install_component.sql',
    'source/install_headless.sql',
    'source/reporters',
    'source/uninstall.log',
    'source/uninstall.sql',
    'source/api/be_between.syn',
    'source/api/be_empty.syn',
    'source/api/be_false.syn',
    'source/api/be_greater_or_equal.syn',
    'source/api/be_greater_than.syn',
    'source/api/be_less_or_equal.syn',
    'source/api/be_less_than.syn',
    'source/api/be_like.syn',
    'source/api/be_not_null.syn',
    'source/api/be_null.syn',
    'source/api/be_true.syn',
    'source/api/equal.syn',
    'source/api/match.syn',
    'source/api/ut.pkb',
    'source/api/ut.pks',
    'source/api/ut_runner.pkb',
    'source/api/ut_runner.pks',
    'source/core/coverage',
    'source/core/output_buffers',
    'source/core/types',
    'source/core/ut_annotations.pkb',
    'source/core/ut_annotations.pks',
    'source/core/ut_expectation_processor.pkb',
    'source/core/ut_expectation_processor.pks',
    'source/core/ut_file_mapper.pkb',
    'source/core/ut_file_mapper.pks',
    'source/core/ut_metadata.pkb',
    'source/core/ut_metadata.pks',
    'source/core/ut_suite_manager.pkb',
    'source/core/ut_suite_manager.pks',
    'source/core/ut_utils.pkb',
    'source/core/ut_utils.pks',
    'source/core/coverage/proftab.sql',
    'source/core/coverage/ut_coverage.pkb',
    'source/core/coverage/ut_coverage.pks',
    'source/core/coverage/ut_coverage_helper.pkb',
    'source/core/coverage/ut_coverage_helper.pks',
    'source/core/coverage/ut_coverage_reporter_base.tpb',
    'source/core/coverage/ut_coverage_reporter_base.tps',
    'source/core/coverage/ut_coverage_sources_tmp.sql',
    'source/core/output_buffers/ut_message_id_seq.sql',
    'source/core/output_buffers/ut_output_buffer_base.tps',
    'source/core/output_buffers/ut_output_buffer_info_tmp.sql',
    'source/core/output_buffers/ut_output_buffer_tmp.sql',
    'source/core/output_buffers/ut_output_table_buffer.tpb',
    'source/core/output_buffers/ut_output_table_buffer.tps',
    'source/core/types/ut_console_reporter_base.tpb',
    'source/core/types/ut_console_reporter_base.tps',
    'source/core/types/ut_coverage_options.tps',
    'source/core/types/ut_event_listener.tpb',
    'source/core/types/ut_event_listener.tps',
    'source/core/types/ut_event_listener_base.tps',
    'source/core/types/ut_executable.tpb',
    'source/core/types/ut_executable.tps',
    'source/core/types/ut_expectation_result.tpb',
    'source/core/types/ut_expectation_result.tps',
    'source/core/types/ut_expectation_results.tps',
    'source/core/types/ut_file_mapping.tpb',
    'source/core/types/ut_file_mapping.tps',
    'source/core/types/ut_file_mappings.tps',
    'source/core/types/ut_key_value_pair.tps',
    'source/core/types/ut_key_value_pairs.tps',
    'source/core/types/ut_logical_suite.tpb',
    'source/core/types/ut_logical_suite.tps',
    'source/core/types/ut_object_name.tpb',
    'source/core/types/ut_object_name.tps',
    'source/core/types/ut_object_names.tps',
    'source/core/types/ut_output_reporter_base.tpb',
    'source/core/types/ut_output_reporter_base.tps',
    'source/core/types/ut_reporters.tps',
    'source/core/types/ut_reporter_base.tpb',
    'source/core/types/ut_reporter_base.tps',
    'source/core/types/ut_results_counter.tpb',
    'source/core/types/ut_results_counter.tps',
    'source/core/types/ut_run.tpb',
    'source/core/types/ut_run.tps',
    'source/core/types/ut_suite.tpb',
    'source/core/types/ut_suite.tps',
    'source/core/types/ut_suite_item.tpb',
    'source/core/types/ut_suite_item.tps',
    'source/core/types/ut_suite_items.tps',
    'source/core/types/ut_suite_item_base.tps',
    'source/core/types/ut_test.tpb',
    'source/core/types/ut_test.tps',
    'source/core/types/ut_varchar2_list.tps',
    'source/core/types/ut_varchar2_rows.tps',
    'source/expectations/data_values',
    'source/expectations/matchers',
    'source/expectations/ut_expectation.tpb',
    'source/expectations/ut_expectation.tps',
    'source/expectations/ut_expectation_anydata.tpb',
    'source/expectations/ut_expectation_anydata.tps',
    'source/expectations/ut_expectation_blob.tpb',
    'source/expectations/ut_expectation_blob.tps',
    'source/expectations/ut_expectation_boolean.tpb',
    'source/expectations/ut_expectation_boolean.tps',
    'source/expectations/ut_expectation_clob.tpb',
    'source/expectations/ut_expectation_clob.tps',
    'source/expectations/ut_expectation_date.tpb',
    'source/expectations/ut_expectation_date.tps',
    'source/expectations/ut_expectation_dsinterval.tpb',
    'source/expectations/ut_expectation_dsinterval.tps',
    'source/expectations/ut_expectation_number.tpb',
    'source/expectations/ut_expectation_number.tps',
    'source/expectations/ut_expectation_refcursor.tpb',
    'source/expectations/ut_expectation_refcursor.tps',
    'source/expectations/ut_expectation_timestamp.tpb',
    'source/expectations/ut_expectation_timestamp.tps',
    'source/expectations/ut_expectation_timestamp_ltz.tpb',
    'source/expectations/ut_expectation_timestamp_ltz.tps',
    'source/expectations/ut_expectation_timestamp_tz.tpb',
    'source/expectations/ut_expectation_timestamp_tz.tps',
    'source/expectations/ut_expectation_varchar2.tpb',
    'source/expectations/ut_expectation_varchar2.tps',
    'source/expectations/ut_expectation_yminterval.tpb',
    'source/expectations/ut_expectation_yminterval.tps',
    'source/expectations/data_values/ut_cursor_data.sql',
    'source/expectations/data_values/ut_data_value.tpb',
    'source/expectations/data_values/ut_data_value.tps',
    'source/expectations/data_values/ut_data_value_anydata.tpb',
    'source/expectations/data_values/ut_data_value_anydata.tps',
    'source/expectations/data_values/ut_data_value_blob.tpb',
    'source/expectations/data_values/ut_data_value_blob.tps',
    'source/expectations/data_values/ut_data_value_boolean.tpb',
    'source/expectations/data_values/ut_data_value_boolean.tps',
    'source/expectations/data_values/ut_data_value_clob.tpb',
    'source/expectations/data_values/ut_data_value_clob.tps',
    'source/expectations/data_values/ut_data_value_collection.tpb',
    'source/expectations/data_values/ut_data_value_collection.tps',
    'source/expectations/data_values/ut_data_value_date.tpb',
    'source/expectations/data_values/ut_data_value_date.tps',
    'source/expectations/data_values/ut_data_value_dsinterval.tpb',
    'source/expectations/data_values/ut_data_value_dsinterval.tps',
    'source/expectations/data_values/ut_data_value_number.tpb',
    'source/expectations/data_values/ut_data_value_number.tps',
    'source/expectations/data_values/ut_data_value_object.tpb',
    'source/expectations/data_values/ut_data_value_object.tps',
    'source/expectations/data_values/ut_data_value_refcursor.tpb',
    'source/expectations/data_values/ut_data_value_refcursor.tps',
    'source/expectations/data_values/ut_data_value_timestamp.tpb',
    'source/expectations/data_values/ut_data_value_timestamp.tps',
    'source/expectations/data_values/ut_data_value_timestamp_ltz.tpb',
    'source/expectations/data_values/ut_data_value_timestamp_ltz.tps',
    'source/expectations/data_values/ut_data_value_timestamp_tz.tpb',
    'source/expectations/data_values/ut_data_value_timestamp_tz.tps',
    'source/expectations/data_values/ut_data_value_varchar2.tpb',
    'source/expectations/data_values/ut_data_value_varchar2.tps',
    'source/expectations/data_values/ut_data_value_yminterval.tpb',
    'source/expectations/data_values/ut_data_value_yminterval.tps',
    'source/expectations/matchers/ut_be_between.tpb',
    'source/expectations/matchers/ut_be_between.tps',
    'source/expectations/matchers/ut_be_empty.tpb',
    'source/expectations/matchers/ut_be_empty.tps',
    'source/expectations/matchers/ut_be_false.tpb',
    'source/expectations/matchers/ut_be_false.tps',
    'source/expectations/matchers/ut_be_greater_or_equal.tpb',
    'source/expectations/matchers/ut_be_greater_or_equal.tps',
    'source/expectations/matchers/ut_be_greater_than.tpb',
    'source/expectations/matchers/ut_be_greater_than.tps',
    'source/expectations/matchers/ut_be_less_or_equal.tpb',
    'source/expectations/matchers/ut_be_less_or_equal.tps',
    'source/expectations/matchers/ut_be_less_than.tpb',
    'source/expectations/matchers/ut_be_less_than.tps',
    'source/expectations/matchers/ut_be_like.tpb',
    'source/expectations/matchers/ut_be_like.tps',
    'source/expectations/matchers/ut_be_not_null.tpb',
    'source/expectations/matchers/ut_be_not_null.tps',
    'source/expectations/matchers/ut_be_null.tpb',
    'source/expectations/matchers/ut_be_null.tps',
    'source/expectations/matchers/ut_be_true.tpb',
    'source/expectations/matchers/ut_be_true.tps',
    'source/expectations/matchers/ut_comparison_matcher.tpb',
    'source/expectations/matchers/ut_comparison_matcher.tps',
    'source/expectations/matchers/ut_equal.tpb',
    'source/expectations/matchers/ut_equal.tps',
    'source/expectations/matchers/ut_match.tpb',
    'source/expectations/matchers/ut_match.tps',
    'source/expectations/matchers/ut_matcher.tpb',
    'source/expectations/matchers/ut_matcher.tps',
    'source/reporters/ut_ansiconsole_helper.pkb',
    'source/reporters/ut_ansiconsole_helper.pks',
    'source/reporters/ut_coverage_html_reporter.tpb',
    'source/reporters/ut_coverage_html_reporter.tps',
    'source/reporters/ut_coverage_report_html_helper.pkb',
    'source/reporters/ut_coverage_report_html_helper.pks',
    'source/reporters/ut_coverage_sonar_reporter.tpb',
    'source/reporters/ut_coverage_sonar_reporter.tps',
    'source/reporters/ut_coveralls_reporter.tpb',
    'source/reporters/ut_coveralls_reporter.tps',
    'source/reporters/ut_documentation_reporter.tpb',
    'source/reporters/ut_documentation_reporter.tps',
    'source/reporters/ut_sonar_test_reporter.tpb',
    'source/reporters/ut_sonar_test_reporter.tps',
    'source/reporters/ut_teamcity_reporter.tpb',
    'source/reporters/ut_teamcity_reporter.tps',
    'source/reporters/ut_teamcity_reporter_helper.pkb',
    'source/reporters/ut_teamcity_reporter_helper.pks',
    'source/reporters/ut_xunit_reporter.tpb',
    'source/reporters/ut_xunit_reporter.tps');

  l_test_run := ut_run(a_items => ut_suite_items(), a_project_file_mappings => ut_file_mapper.build_file_mappings( user,l_project_file_list));

  --run for the first time to gather coverage and timings on reporters too
  l_reporter := ut_coverage_html_reporter(a_project_name => 'utPLSQL v3');
  l_reporter.after_calling_run(l_test_run);
  l_reporter.finalize();

  l_reporter := ut_coverage_sonar_reporter();
  l_reporter.after_calling_run(l_test_run);
  l_reporter.finalize();

  l_reporter := ut_coveralls_reporter();
  l_reporter.after_calling_run(l_test_run);
  l_reporter.finalize();

  ut_coverage.coverage_stop_develop();

  --run for the second time to get the coverage report
  l_reporter := ut_coverage_html_reporter(a_project_name => 'utPLSQL v3');
  l_reporter.after_calling_run(l_test_run);
  l_reporter.finalize();
  :html_reporter_id := l_reporter.get_reporter_id;

  l_reporter := ut_coverage_sonar_reporter();
  l_reporter.after_calling_run(l_test_run);
  l_reporter.finalize();
  :sonar_reporter_id := l_reporter.get_reporter_id;

  l_reporter := ut_coveralls_reporter();
  l_reporter.after_calling_run(l_test_run);
  l_reporter.finalize();
  :coveralls_reporter_id := l_reporter.get_reporter_id;
end;
/

set timing off
prompt Spooling outcomes to coverage.xml
set termout off
set feedback off
set arraysize 50
spool coverage.xml
declare
  l_reporter ut_output_reporter_base := ut_coverage_sonar_reporter();
begin
  l_reporter.set_reporter_id(:sonar_reporter_id);
  l_reporter.lines_to_dbms_output(a_initial_timeout=>1, a_timeout_sec=>1);
end;
/
spool off

set termout on
prompt Spooling outcomes to coverage.json
set termout off
spool coverage.json
declare
  l_reporter ut_output_reporter_base := ut_coveralls_reporter();
begin
  l_reporter.set_reporter_id(:coveralls_reporter_id);
  l_reporter.lines_to_dbms_output(a_initial_timeout=>1, a_timeout_sec=>1);
end;
/
spool off

set termout on
prompt Spooling outcomes to coverage.html
set termout off
spool coverage.html
declare
  l_reporter ut_output_reporter_base := ut_coverage_html_reporter();
begin
  l_reporter.set_reporter_id(:html_reporter_id);
  l_reporter.lines_to_dbms_output(a_initial_timeout=>1, a_timeout_sec=>1);
end;
/
spool off

set termout on
spool stats.log
exec mystats_pkg.ms_stop(1000);
spool off

--can be used by CI to check for tests status
exit :failures_count
