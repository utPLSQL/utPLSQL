PROMPT Gives a failure when comparing blob to clob values
@@asssertions/common/ut.expect.to_equal.different_scalars.common.sql 'blob' 'clob' 'to_blob(''ABC'')' '''ABC'''

PROMPT Gives a failure when comparing clob to varchar2 values
@@asssertions/common/ut.expect.to_equal.different_scalars.common.sql 'clob' 'varchar2(4000)' '''Abc''' '''Abc'''

PROMPT Gives a failure when comparing date to timestamp values
@@asssertions/common/ut.expect.to_equal.different_scalars.common.sql 'date' 'timestamp' 'sysdate' 'sysdate'

PROMPT Gives a failure when comparing timestamp with local time zone to timestamp values
@@asssertions/common/ut.expect.to_equal.different_scalars.common.sql 'timestamp with local time zone' 'timestamp' 'sysdate' 'sysdate'

PROMPT Gives a failure when comparing timestamp with local time zone to timestamp with time zone values
@@asssertions/common/ut.expect.to_equal.different_scalars.common.sql 'timestamp with local time zone' 'timestamp with time zone' 'sysdate' 'sysdate'

PROMPT Gives a failure when comparing number to varchar2 values
@@asssertions/common/ut.expect.to_equal.different_scalars.common.sql 'number' 'varchar2(4000)' '1' '''1'''

