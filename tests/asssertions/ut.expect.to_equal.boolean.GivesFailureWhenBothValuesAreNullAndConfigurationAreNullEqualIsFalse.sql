PROMPT Gives failure when both boolean values are null and configuration nulls_are_equal is false

exec ut_assert_processor.nulls_Are_equal(false);
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'boolean' 'NULL' 'NULL' 'ut_utils.tr_failure'
exec ut_assert_processor.nulls_Are_equal(true);
