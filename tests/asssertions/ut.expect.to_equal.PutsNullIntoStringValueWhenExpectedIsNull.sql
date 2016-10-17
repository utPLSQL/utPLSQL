PROMPT Puts 'NULL' into assert results when expected blob value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'blob' 'to_blob(''abc'')' 'NULL' 'expected_value_string'

PROMPT Puts 'NULL' into assert results when expected boolean value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'boolean' 'false' 'NULL' 'expected_value_string'

PROMPT Puts 'NULL' into assert results when expected clob value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'clob' '''abc''' 'NULL' 'expected_value_string'

PROMPT Puts 'NULL' into assert results when expected date value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'date' 'sysdate' 'NULL' 'expected_value_string'

PROMPT Puts 'NULL' into assert results when expected number value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'number' '1234' 'NULL' 'expected_value_string'

PROMPT Puts 'NULL' into assert results when expected timestamp value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'timestamp' 'systimestamp' 'NULL' 'expected_value_string'

PROMPT Puts 'NULL' into assert results when expected timestamp with local time zone value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'timestamp with local time zone' 'systimestamp' 'NULL' 'expected_value_string'

PROMPT Puts 'NULL' into assert results when expected timestamp with time zone value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'timestamp with time zone' 'systimestamp' 'NULL' 'expected_value_string'

PROMPT Puts 'NULL' into assert results when expected varchar2 value is null
@@asssertions/common/ut.expect.to_equal.scalar.null_value_text.common.sql 'varchar2(4000)' '''abc''' 'NULL' 'expected_value_string'
