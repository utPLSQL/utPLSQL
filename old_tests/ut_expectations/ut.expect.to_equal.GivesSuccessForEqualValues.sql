@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'blob' 'to_blob(''Abc'')' 'to_blob(''abc'')' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'boolean' 'true' 'true' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'clob' '''Abc''' '''Abc''' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'date' 'sysdate' 'sysdate' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'number' '12345' '12345' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'timestamp(9)' 'to_Timestamp(''2016 123456789'',''yyyy ff'')' 'to_Timestamp(''2016 123456789'',''yyyy ff'')' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'timestamp(9) with local time zone' 'to_Timestamp(''2016 123456789'',''yyyy ff'')' 'to_Timestamp(''2016 123456789'',''yyyy ff'')'  'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'timestamp(9) with time zone' 'to_Timestamp(''2016 123456789'',''yyyy ff'')' 'to_Timestamp(''2016 123456789'',''yyyy ff'')' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'varchar2(4000)' '''Abc''' '''Abc''' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'interval day to second' '''2 01:00:00''' '''2 01:00:00'''"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'interval year to month' '''1-1''' '''1-1'''"




