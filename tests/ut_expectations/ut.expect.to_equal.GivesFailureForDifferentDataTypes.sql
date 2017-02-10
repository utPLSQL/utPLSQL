@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.different_scalars.common.sql 'blob' 'clob' 'to_blob(''ABC'')' '''ABC'''"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.different_scalars.common.sql 'clob' 'varchar2(4000)' '''Abc''' '''Abc'''"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.different_scalars.common.sql 'date' 'timestamp' 'sysdate' 'sysdate'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.different_scalars.common.sql 'timestamp with local time zone' 'timestamp' 'sysdate' 'sysdate'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.different_scalars.common.sql 'timestamp with local time zone' 'timestamp with time zone' 'sysdate' 'sysdate'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.different_scalars.common.sql 'number' 'varchar2(4000)' '1' '''1'''"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.different_scalars.common.sql 'interval day to second' 'interval year to month' '''2 01:00:00''' '''1-1'''"

