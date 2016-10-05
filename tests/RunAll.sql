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
@@helpers/test_pkg1.pck

--Tests to invoke
@@lib/RunTest.sql ut_test/ut_test.OwnerNameInvalid.sql
@@lib/RunTest.sql ut_test/ut_test.OwnerNameNull.sql
@@lib/RunTest.sql ut_test/ut_test.PackageInInvalidState.sql
@@lib/RunTest.sql ut_test/ut_test.PackageNameInvalid.sql
@@lib/RunTest.sql ut_test/ut_test.PackageNameNull.sql
@@lib/RunTest.sql ut_test/ut_test.ProcedureNameInvalid.sql
@@lib/RunTest.sql ut_test/ut_test.ProcedureNameNull.sql
@@lib/RunTest.sql ut_test/ut_test.SetupExecutedBeforeTest.sql
@@lib/RunTest.sql ut_test/ut_test.SetupProcedureNameInvalid.sql
@@lib/RunTest.sql ut_test/ut_test.SetupProcedureNameNull.sql
@@lib/RunTest.sql ut_test/ut_test.TeardownExecutedAfterTest.sql
@@lib/RunTest.sql ut_test/ut_test.TeardownProcedureNameInvalid.sql
@@lib/RunTest.sql ut_test/ut_test.TeardownProcedureNameNull.sql
@@lib/RunTest.sql ut_utils/ut_utils.test_result_to_char.RunsWithInvalidValues.sql
@@lib/RunTest.sql ut_utils/ut_utils.test_result_to_char.RunsWithNullValue.sql
@@lib/RunTest.sql ut_utils/ut_utils.test_result_to_char.Success.sql

@@lib/RunTest.sql ut_metadata/ut_metadata.form_name.TrimStandaloneProgramName.sql

@@lib/RunTest.sql ut_assert/ut_assert.are_equal.number.GivesSuccessForEqualValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.number.GivesFailureForDifferentValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.number.GivesFailureWhenActualIsNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.number.GivesFailureWhenBothAreNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.number.GivesFailureWhenExpectedIsNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.number.with_text.GivesTheProvidedTextAsMessage.sql

@@lib/RunTest.sql ut_assert/ut_assert.are_equal.anydata.GivesSuccessWhenComparingTheSameData.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.anydata.GivesFailureWhenComparingDifferentData.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.anydata.PutsObjectStrucureIntoAssert.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.cursor.GivesFailureWhenComparingDifferentResultSets.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.cursor.GivesSuccessWhenComparingIdenticalResultSets.sql

@@lib/RunTest.sql ut_assert/ut_assert.this.GivesFailureWhenExpressionEvaluatesToFalse.sql
@@lib/RunTest.sql ut_assert/ut_assert.this.GivesFailureWhenExpressionEvaluatesToNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.this.GivesSuccessWhenExpressionEvaluatesToTrue.sql

@@lib/RunTest.sql ut_assert/ut_assert.are_equal.varchar2.GivesFailureForDifferentValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.varchar2.GivesFailureWhenActualIsNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.varchar2.GivesFailureWhenBothAreNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.varchar2.GivesFailureWhenExpectedIsNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.varchar2.GivesSuccessForEqualValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.varchar2.with_text.GivesTheProvidedTextAsMessage.sql

@@lib/RunTest.sql ut_assert/ut_assert.are_equal.date.GivesFailureForDifferentValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.date.GivesFailureWhenActualIsNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.date.GivesFailureWhenBothAreNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.date.GivesFailureWhenExpectedIsNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.date.GivesSuccessForEqualValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.date.with_text.GivesTheProvidedTextAsMessage.sql

@@lib/RunTest.sql ut_assert/ut_assert.are_equal.timestamp.GivesFailureForDifferentValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.timestamp.GivesFailureWhenActualIsNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.timestamp.GivesFailureWhenBothAreNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.timestamp.GivesFailureWhenExpectedIsNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.timestamp.GivesSuccessForEqualValues.sql
@@lib/RunTest.sql ut_assert/ut_assert.are_equal.timestamp.with_text.GivesTheProvidedTextAsMessage.sql

@@lib/RunTest.sql ut_assert/ut_assert.are_equal.scalar.FailsToExecuteWhenNullsPassedAsParameters.sql

@@lib/RunTest.sql ut_assert/ut_assert.is_not_null.date.GivesFailureForNullValue.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_not_null.date.GivesSuccessForNotNullValue.sql

@@lib/RunTest.sql ut_assert/ut_assert.is_null.anydata.GivesFailureWhenDataIsNotNull.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_null.anydata.GivesSuccessWhenDataIsNull.sql

@@lib/RunTest.sql ut_assert/ut_assert.is_null.date.GivesFailureForNotNullValue.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_null.date.GivesSuccessForNullValue.sql

@@lib/RunTest.sql ut_assert/ut_assert.is_like.GivesSuccessForLikeString.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_like.GivesSuccessForLikeStringWithEscape.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_like.GivesFailureForLikeString.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_like.GivesFailureForLikeStringWithEscape.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_matching.GivesSuccessForMatchingString.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_matching.GivesSuccessForMatchingStringWithModifier.sql
@@lib/RunTest.sql ut_assert/ut_assert.is_matching.GivesFailureForMatchingString.sql

@@lib/RunTest.sql ut_utils/ut_utils.to_string.verySmallNumber.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.veryBigNumber.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.Date.sql
@@lib/RunTest.sql ut_utils/ut_utils.to_string.Timestamp.sql


@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotation.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotationWithMultilineComment.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageLevelAnnotationWithKeyValue.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParseAnnotationNotBeforeProcedure.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParsePackageAndProcedureLevelAnnotations.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParseAnnotationMixedWithWrongBeforeProcedure.sql
@@lib/RunTest.sql ut_annotations/ut_annotations.parse_package_annotations.ParseComplexPackage.sql



@@lib/RunTest.sql ut_annotations_cache/ut_annotations_cache.AutoPurgeCache.sql
@@lib/RunTest.sql ut_annotations_cache/ut_annotations_cache.is_cache_valid.ReturnsFalseIfCacheNeedsRefresh.sql
@@lib/RunTest.sql ut_annotations_cache/ut_annotations_cache.is_cache_valid.ReturnsTrueIfCacheIsUpToDate.sql
@@lib/RunTest.sql ut_annotations_cache/ut_annotations_cache.purge_cache.ForAPackage.sql
@@lib/RunTest.sql ut_annotations_cache/ut_annotations_cache.purge_cache.sql
@@lib/RunTest.sql ut_annotations_cache/ut_annotations_cache.save_and_retrieve.sql

--Global cleanup
drop package ut_example_tests;
drop procedure check_annotation_parsing;
drop package test_pkg1;

--Finally
@@lib/RunSummary
--can be used by CI to check for tests status
exit :failures_count
