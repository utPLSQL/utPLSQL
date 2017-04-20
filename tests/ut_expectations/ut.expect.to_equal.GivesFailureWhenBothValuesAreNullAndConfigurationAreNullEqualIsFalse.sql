exec ut_expectation_processor.nulls_Are_equal(false);
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'blob' 'NULL' 'NULL' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'boolean' 'NULL' 'NULL' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'clob' 'NULL' 'NULL' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'date' 'NULL' 'NULL' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'number' 'NULL' 'NULL' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'timestamp' 'NULL' 'NULL' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'timestamp with local time zone' 'NULL' 'NULL' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'timestamp with time zone' 'NULL' 'NULL' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'varchar2(4000)' 'NULL' 'NULL' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'interval day to second' 'NULL' 'NULL' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_equal.scalar.common.sql 'interval year to month' 'NULL' 'NULL' 'ut_utils.tr_failure'"
exec ut_expectation_processor.nulls_Are_equal(ut_expectation_processor.gc_default_nulls_are_equal);
