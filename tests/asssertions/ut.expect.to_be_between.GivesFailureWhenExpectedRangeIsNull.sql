exec ut_assert_processor.nulls_Are_equal(true);
PROMPT Gives failure when expected lower bound date value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'date' 'sysdate' 'NULL' 'sysdate' 'ut_utils.tr_failure'

PROMPT Gives failure when expected lower bound number value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'number' '1234' 'NULL' '1234' 'ut_utils.tr_failure'

PROMPT Gives failure when expected lower bound timestamp value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp' 'systimestamp' 'NULL' 'systimestamp' 'ut_utils.tr_failure'

PROMPT Gives failure when expected lower bound timestamp with local time zone value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp with local time zone' 'systimestamp' 'NULL' 'systimestamp' 'ut_utils.tr_failure'

PROMPT Gives failure when expected lower bound timestamp with time zone value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp with time zone' 'systimestamp' 'NULL' 'systimestamp' 'ut_utils.tr_failure'


PROMPT Gives failure when expected upper bound date value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'date' 'sysdate' 'sysdate' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when expected upper bound number value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'number' '1234' '1234' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when expected upper bound timestamp value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp' 'systimestamp' 'systimestamp' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when expected upper bound timestamp with local time zone value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp with local time zone' 'systimestamp' 'systimestamp' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when expected upper bound timestamp with time zone value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp with time zone' 'systimestamp' 'systimestamp' 'NULL' 'ut_utils.tr_failure'


PROMPT Gives failure when expected range date value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'date' 'sysdate' 'NULL' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when expected range number value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'number' '1234' 'NULL' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when expected range timestamp value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp' 'systimestamp' 'NULL' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when expected range timestamp with local time zone value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp with local time zone' 'systimestamp' 'NULL' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when expected range timestamp with time zone value is null
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp with time zone' 'systimestamp' 'NULL' 'NULL' 'ut_utils.tr_failure'

