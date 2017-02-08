@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.be_empty.sql 'select * from dual where 1 = 1' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.be_empty.sql 'select * from dual where 1 <> 1' 'ut_utils.tr_success'"

@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.not_to_be_empty.sql 'select * from dual where 1 = 1' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.not_to_be_empty.sql 'select * from dual where 1 <> 1' 'ut_utils.tr_failure'"
