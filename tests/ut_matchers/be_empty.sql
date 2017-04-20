@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.refcursor.be_empty.sql 'select * from dual where 1 = 1' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.refcursor.be_empty.sql 'select * from dual where 1 <> 1' 'ut_utils.tr_success'"

@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.refcursor.not_to_be_empty.sql 'select * from dual where 1 = 1' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.refcursor.not_to_be_empty.sql 'select * from dual where 1 <> 1' 'ut_utils.tr_failure'"

@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.collection.be_empty.sql 'ora_mining_varchar2_nt' 'ora_mining_varchar2_nt()' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.collection.be_empty.sql 'ora_mining_varchar2_nt' 'ora_mining_varchar2_nt(''a'')' 'ut_utils.tr_failure'"

@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.collection.not_be_empty.sql 'ora_mining_varchar2_nt' 'ora_mining_varchar2_nt()' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.collection.not_be_empty.sql 'ora_mining_varchar2_nt' 'ora_mining_varchar2_nt(''a'')' 'ut_utils.tr_success'"

@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.other.be_empty.sql 'ut_data_value_number' 'ut_data_value_number(1)' 'ConvertObject' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.other.not_be_empty.sql 'ut_data_value_varchar2' 'NULL' 'ConvertObject' 'ut_utils.tr_failure'"

@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.refcursor.null.be_empty.sql 'to_' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.common.refcursor.null.be_empty.sql 'not_to' 'ut_utils.tr_failure'"
