@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.with_message.common.sql 'blob' 'to_blob(''abcd'')' 'to_blob(''abc'')'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.with_message.common.sql 'boolean' 'false' 'true'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.with_message.common.sql 'clob' '''abcd''' '''abc'''"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.with_message.common.sql 'date' 'sysdate-1' 'sysdate'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.with_message.common.sql 'number' '2' '1'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.with_message.common.sql 'timestamp' 'sysdate-1' 'sysdate'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.with_message.common.sql 'timestamp with local time zone' 'sysdate-1' 'sysdate'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.with_message.common.sql 'timestamp with time zone' 'sysdate-1' 'sysdate'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.with_message.common.sql 'varchar2(100)' '''abcd''' '''abc'''"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.with_message.common.sql 'interval day to second' '''2 01:01:00''' '''2 01:00:00'''"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.with_message.common.sql 'interval year to month' '''1-2''' '''1-1'''"





