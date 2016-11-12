PROMPT GGives a success when comparing equal date values
@@asssertions/common/ut.expect.to_be_between.scalar.with_message.common.sql 'date' 'sysdate' 'sysdate-1' 'sysdate+1'

PROMPT GGives a success when comparing equal number values
@@asssertions/common/ut.expect.to_be_between.scalar.with_message.common.sql 'number' '0.4' '0.3' '0.5'

PROMPT GGives a success when comparing timestamp values
@@asssertions/common/ut.expect.to_be_between.scalar.with_message.common.sql 'timestamp' 'systimestamp' 'systimestamp-1' 'systimestamp'

PROMPT GGives a success when comparing timestamp with local time zone values
@@asssertions/common/ut.expect.to_be_between.scalar.with_message.common.sql 'timestamp with local time zone' 'systimestamp' 'systimestamp-1' 'systimestamp'

PROMPT GGives a success when comparingtimestamp with time zone values
@@asssertions/common/ut.expect.to_be_between.scalar.with_message.common.sql 'timestamp with time zone' 'systimestamp' 'systimestamp-1' 'systimestamp'
