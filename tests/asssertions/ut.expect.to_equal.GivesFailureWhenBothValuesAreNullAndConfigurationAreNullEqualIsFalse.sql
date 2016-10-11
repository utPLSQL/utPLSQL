exec ut_assert_processor.nulls_Are_equal(false);

PROMPT Gives failure when both blob values are null and configuration nulls_are_equal is false
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'blob' 'NULL' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when both boolean values are null and configuration nulls_are_equal is false
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'boolean' 'NULL' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when both clob values are null and configuration nulls_are_equal is false
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'clob' 'NULL' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when both date values are null and configuration nulls_are_equal is false
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'date' 'NULL' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when both number values are null and configuration nulls_are_equal is false
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'number' 'NULL' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when both timestamp values are null and configuration nulls_are_equal is false
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'timestamp' 'NULL' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when both timestamp with local time zone values are null and configuration nulls_are_equal is false
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'timestamp with local time zone' 'NULL' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when both timestamp with time zone values are null and configuration nulls_are_equal is false
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'timestamp with time zone' 'NULL' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when both varchar2 values are null and configuration nulls_are_equal is false
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'varchar2(4000)' 'NULL' 'NULL' 'ut_utils.tr_failure'

exec ut_assert_processor.nulls_Are_equal(ut_assert_processor.gc_default_nulls_are_equal);
