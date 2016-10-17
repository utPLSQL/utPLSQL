PROMPT Puts 'NULL' into assert results when actual blob value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'blob' 'NULL' 'to_blob(''abc'')' 'actual_value_string'

PROMPT Puts 'NULL' into assert results when actual boolean value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'boolean' 'NULL' 'false' 'actual_value_string'

PROMPT Puts 'NULL' into assert results when actual clob value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'clob' 'NULL' '''abc''' 'actual_value_string'

PROMPT Puts 'NULL' into assert results when actual date value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'date' 'NULL' 'sysdate' 'actual_value_string'

PROMPT Puts 'NULL' into assert results when actual number value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'number' 'NULL' '1234' 'actual_value_string'

PROMPT Puts 'NULL' into assert results when actual timestamp value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'timestamp' 'NULL' 'systimestamp' 'actual_value_string'

PROMPT Puts 'NULL' into assert results when actual timestamp with local time zone value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'timestamp with local time zone' 'NULL' 'systimestamp' 'actual_value_string'

PROMPT Puts 'NULL' into assert results when actual timestamp with time zone value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'timestamp with time zone' 'NULL' 'systimestamp' 'actual_value_string'

PROMPT Puts 'NULL' into assert results when actual varchar2 value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'varchar2(4000)' 'NULL' '''abc''' 'actual_value_string'

