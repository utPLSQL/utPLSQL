@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_be_between.scalar.common.sql 'date' 'sysdate+2' 'sysdate-1' 'sysdate' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_be_between.scalar.common.sql 'number' '0.1' '0.3' '0.5' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_be_between.scalar.common.sql 'timestamp' 'systimestamp' 'systimestamp' 'systimestamp' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_be_between.scalar.common.sql 'timestamp with local time zone' 'systimestamp' 'systimestamp' 'systimestamp' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_be_between.scalar.common.sql 'timestamp with time zone' 'systimestamp' 'systimestamp' 'systimestamp' 'ut_utils.tr_failure'"
