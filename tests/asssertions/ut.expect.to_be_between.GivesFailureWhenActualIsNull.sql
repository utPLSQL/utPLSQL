exec ut_assert_processor.nulls_Are_equal(true);
PROMPT Gives failure when actual date value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'date' 'NULL' 'sysdate-1' 'sysdate' 'ut_utils.tr_failure'

PROMPT Gives failure when actual number value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'number' 'NULL' '0' '1' 'ut_utils.tr_failure'

PROMPT Gives failure when actual timestamp value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp' 'NULL' 'systimestamp-1' 'systimestamp' 'ut_utils.tr_failure'

PROMPT Gives failure when actual timestamp with local time zone value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp with local time zone' 'NULL' 'systimestamp-1' 'systimestamp' 'ut_utils.tr_failure'

PROMPT Gives failure when actual timestamp with time zone value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp with time zone' 'NULL' 'systimestamp-1' 'systimestamp' 'ut_utils.tr_failure'

