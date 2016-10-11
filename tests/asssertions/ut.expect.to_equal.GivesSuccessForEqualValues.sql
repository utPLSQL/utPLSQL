PROMPT Gives a success when comparing equal blob values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'blob' 'to_blob(''Abc'')' 'to_blob(''abc'')' 'ut_utils.tr_success'

PROMPT Gives a success when comparing equal boolean values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'boolean' 'false' 'false' 'ut_utils.tr_success'

PROMPT Gives a success when comparing equal clob values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'clob' '''Abc''' '''Abc''' 'ut_utils.tr_success'

PROMPT Gives a success when comparing equal date values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'date' 'sysdate' 'sysdate' 'ut_utils.tr_success'

PROMPT Gives a success when comparing equal number values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'number' '12345' '12345' 'ut_utils.tr_success'

PROMPT Gives a success when comparing equal timestamp values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'timestamp' 'to_timestamp(sysdate)' 'to_timestamp(sysdate)' 'ut_utils.tr_success'

PROMPT Gives a success when comparing equal timestamp with local time zone values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'timestamp with local time zone' 'to_timestamp(sysdate)' 'to_timestamp(sysdate)' 'ut_utils.tr_success'

PROMPT Gives a success when comparing equal timestamp with time zone values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'timestamp with time zone' 'to_timestamp(sysdate)' 'to_timestamp(sysdate)' 'ut_utils.tr_success'

PROMPT Gives a success when comparing equal varchar2 values
@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'varchar2(4000)' '''Abc''' '''Abc''' 'ut_utils.tr_success'




