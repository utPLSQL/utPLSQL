set echo off
set feedback off
set verify off
Clear Screen
set linesize 5000
set pagesize 0
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

--Tests to invoke

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
@@lib/RunTest.sql asssertions/ut.expect.to_match.sql
@@lib/RunTest.sql asssertions/ut_assert_processor.nulls_are_equal.raisesExceptionWhenTryingToSetNullValue.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParseAnnotationMixedWithWrongBeforeProcedure.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParseAnnotationNotBeforeProcedure.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParseComplexPackage.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageAndProcedureLevelAnnotations.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotation.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotationWithKeyValue.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotationWithMultilineComment.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.anydata.GivesFailureWhenComparingDifferentData.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.anydata.GivesSuccessWhenComparingTheSameData.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.anydata.PutsObjectStrucureIntoAssert.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.cursor.GivesFailureWhenComparingDifferentResultSets.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.cursor.GivesSuccessWhenComparingIdenticalResultSets.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.date.GivesFailureForDifferentValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.date.GivesFailureWhenActualIsNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.date.GivesFailureWhenExpectedIsNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.date.GivesSuccessForEqualValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.date.GivesSuccessWhenBothAreNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.date.with_text.GivesTheProvidedTextAsMessage.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.number.GivesFailureForDifferentValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.number.GivesFailureWhenActualIsNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.number.GivesFailureWhenExpectedIsNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.number.GivesSuccessForEqualValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.number.GivesSuccessWhenBothAreNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.number.with_text.GivesTheProvidedTextAsMessage.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.scalar.FailsToExecuteWhenNullsPassedAsParameters.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.timestamp.GivesFailureForDifferentValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.timestamp.GivesFailureWhenActualIsNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.timestamp.GivesFailureWhenExpectedIsNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.timestamp.GivesSuccessForEqualValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.timestamp.GivesSuccessWhenBothAreNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.timestamp.with_text.GivesTheProvidedTextAsMessage.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.timestamp_ltz.GivesSuccessForEqualValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.timestamp_tz.GivesSuccessForEqualValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.varchar2.GivesFailureForDifferentValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.varchar2.GivesFailureWhenActualIsNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.varchar2.GivesFailureWhenExpectedIsNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.varchar2.GivesSuccessForEqualValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.varchar2.GivesSuccessWhenBothAreNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.varchar2.with_text.GivesTheProvidedTextAsMessage.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_like.GivesFailureForLikeString.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_like.GivesFailureForLikeStringWithEscape.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_like.GivesSuccessForLikeString.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_like.GivesSuccessForLikeStringWithEscape.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_matching.GivesFailureForMatchingString.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_matching.GivesSuccessForMatchingString.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_matching.GivesSuccessForMatchingStringWithModifier.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_not_null.date.GivesFailureForNullValue.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_not_null.date.GivesSuccessForNotNullValue.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_null.anydata.GivesFailureWhenDataIsNotNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_null.anydata.GivesSuccessWhenDataIsNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_null.date.GivesFailureForNotNullValue.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_null.date.GivesSuccessForNullValue.sql
@@lib/RunTest.sql ut_assert/ut_assert.this.GivesFailureWhenExpressionEvaluatesToFalse.sql
@@lib/RunTest.sql ut_assert/ut_assert.this.GivesFailureWhenExpressionEvaluatesToNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.this.GivesSuccessWhenExpressionEvaluatesToTrue.sql
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

--Global cleanup
drop package ut_example_tests;
drop procedure check_annotation_parsing;
drop package ut_transaction_control;
drop table ut$test_table;
drop type department$;

--Finally
@@lib/RunSummary
--can be used by CI to check for tests status
exit :failures_count
