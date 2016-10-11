PROMPT Gives failure when expected blob value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'blob' 'to_blob(''abc'')' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when expected boolean value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'boolean' 'true' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when expected clob value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'clob' '''abc''' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when expected date value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'date' 'sysdate' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when expected number value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'number' '1234' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when expected timestamp value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'timestamp' 'systimestamp' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when expected timestamp with local time zone value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'timestamp with local time zone' 'systimestamp' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when expected timestamp with time zone value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'timestamp with time zone' 'systimestamp' 'NULL' 'ut_utils.tr_failure'

PROMPT Gives failure when expected varchar2 value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'varchar2(4000)' '''abc''' 'NULL' 'ut_utils.tr_failure'
