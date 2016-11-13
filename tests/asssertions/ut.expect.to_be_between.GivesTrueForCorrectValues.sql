PROMPT Gives a success when comparing date values
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'date' 'sysdate' 'sysdate-1' 'sysdate+1' 'ut_utils.tr_success'

PROMPT Gives a success when comparing number values
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'number' '0.4' '0.3' '0.5' 'ut_utils.tr_success'

PROMPT Gives a success when comparing varchar2 values
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'varchar2(50)' '''b''' '''a''' '''c''' 'ut_utils.tr_success'

PROMPT Gives a success when comparing timestamp values
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp' 'systimestamp' 'systimestamp-1' 'systimestamp' 'ut_utils.tr_success'

PROMPT Gives a success when comparing timestamp with local time zone values
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp with local time zone' 'systimestamp' 'systimestamp-1' 'systimestamp' 'ut_utils.tr_success'

PROMPT Gives a success when comparing timestamp with time zone values
@@asssertions/common/ut.expect.to_be_between.scalar.common.sql 'timestamp with time zone' 'systimestamp' 'systimestamp-1' 'systimestamp' 'ut_utils.tr_success'
