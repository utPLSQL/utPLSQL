PROMPT Gives failure when actual blob value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'blob' 'NULL' 'to_blob(''abc'')' 'ut_utils.tr_failure'

PROMPT Gives failure when actual boolean value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'boolean' 'NULL' 'true' 'ut_utils.tr_failure'

PROMPT Gives failure when actual clob value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'clob' 'NULL' '''abc''' 'ut_utils.tr_failure'

PROMPT Gives failure when actual date value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'date' 'NULL' 'sysdate' 'ut_utils.tr_failure'

PROMPT Gives failure when actual number value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'number' 'NULL' '1' 'ut_utils.tr_failure'

PROMPT Gives failure when actual timestamp value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'timestamp' 'NULL' 'systimestamp' 'ut_utils.tr_failure'

PROMPT Gives failure when actual timestamp with local time zone value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'timestamp with local time zone' 'NULL' 'systimestamp' 'ut_utils.tr_failure'

PROMPT Gives failure when actual timestamp with time zone value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'timestamp with time zone' 'NULL' 'systimestamp' 'ut_utils.tr_failure'

PROMPT Gives failure when actual varchar2 value is null
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'varchar2(4000)' 'NULL' '''abc''' 'ut_utils.tr_failure'
