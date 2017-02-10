@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.refcursor.be_empty.sql 'select * from dual where 1 = 1' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.refcursor.be_empty.sql 'select * from dual where 1 <> 1' 'ut_utils.tr_success'"

@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.refcursor.not_to_be_empty.sql 'select * from dual where 1 = 1' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.refcursor.not_to_be_empty.sql 'select * from dual where 1 <> 1' 'ut_utils.tr_failure'"

@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.collection.be_empty.sql 'ora_mining_varchar2_nt' 'ora_mining_varchar2_nt()' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.collection.be_empty.sql 'ora_mining_varchar2_nt' 'ora_mining_varchar2_nt(''a'')' 'ut_utils.tr_failure'"

@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.collection.not_be_empty.sql 'ora_mining_varchar2_nt' 'ora_mining_varchar2_nt()' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.collection.not_be_empty.sql 'ora_mining_varchar2_nt' 'ora_mining_varchar2_nt(''a'')' 'ut_utils.tr_failure'"

@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.other.be_empty.sql 'varchar2(1)' '''a''' 'ConvertVarchar' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.other.not_be_empty.sql 'number' 'NULL' 'ConvertNumber' 'ut_utils.tr_failure'"