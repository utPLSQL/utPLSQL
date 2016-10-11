PROMPT Gives a failure when comparing different blob values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'blob' 'to_blob(''abc'')' 'to_blob(''abd'')' 'ut_utils.tr_failure'

PROMPT Gives a failure when comparing different boolean values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'boolean' 'true' 'false' 'ut_utils.tr_failure'

PROMPT Gives a failure when comparing different clob values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'clob' '''Abc''' '''abc''' 'ut_utils.tr_failure'

PROMPT Gives a failure when comparing different date values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'date' 'sysdate' 'sysdate-1' 'ut_utils.tr_failure'

PROMPT Gives a failure when comparing different number values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'number' '0.1' '0.3' 'ut_utils.tr_failure'

PROMPT Gives a failure when comparing different timestamp values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'timestamp' 'systimestamp' 'systimestamp' 'ut_utils.tr_failure'

PROMPT Gives a failure when comparing different timestamp with local time zone values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'timestamp with local time zone' 'systimestamp' 'systimestamp' 'ut_utils.tr_failure'

PROMPT Gives a failure when comparing different timestamp with time zone values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'timestamp with time zone' 'systimestamp' 'systimestamp' 'ut_utils.tr_failure'

PROMPT Gives a failure when comparing different varchar2 values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'varchar2(4000)' '''Abc''' '''abc''' 'ut_utils.tr_failure'
