exec ut_assert_processor.nulls_Are_equal(true);
PROMPT Gives failure when actual value and expected range date value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'date' 'NULL' 'NULL' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when actual value and expected range number value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'number' 'NULL' 'NULL' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when actual value and expected range timestamp value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp' 'NULL' 'NULL' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when actual value and expected range timestamp with local time zone value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp with local time zone' 'NULL' 'NULL' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when actual value and expected range timestamp with time zone value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp with time zone' 'NULL' 'NULL' 'NULL' 'ut_utils.tr_failure'

