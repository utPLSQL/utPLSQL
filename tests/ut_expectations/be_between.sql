PROMPT Be between

@@ut_expectations/common/ut.expect.common.be_between.sql 'date' 'sysdate' 'sysdate-2' 'sysdate-1' 'ut_utils.tr_failure'
@@ut_expectations/common/ut.expect.common.be_between.sql 'number' '2.0' '1.99' '1.999' 'ut_utils.tr_failure'
@@ut_expectations/common/ut.expect.common.be_between.sql 'varchar2(1)' '''c''' '''a''' '''b''' 'ut_utils.tr_failure'
@@ut_expectations/common/ut.expect.common.be_between.sql 'interval year to month' '''2-2''' '''2-0''' '''2-1''' 'ut_utils.tr_failure'
@@ut_expectations/common/ut.expect.common.be_between.sql 'interval day to second' '''2 01:00:00''' '''2 00:59:58''' '''2 00:59:59''' 'ut_utils.tr_failure'

@@ut_expectations/common/ut.expect.common.be_between.sql 'date' 'sysdate' 'sysdate-1' 'sysdate+1' 'ut_utils.tr_success'
@@ut_expectations/common/ut.expect.common.be_between.sql 'number' '2.0' '1.99' '2.01' 'ut_utils.tr_success'
@@ut_expectations/common/ut.expect.common.be_between.sql 'varchar2(1)' '''b''' '''a''' '''c''' 'ut_utils.tr_success'
@@ut_expectations/common/ut.expect.common.be_between.sql 'interval year to month' '''2-1''' '''2-0''' '''2-2''' 'ut_utils.tr_success'
@@ut_expectations/common/ut.expect.common.be_between.sql 'interval day to second' '''2 01:00:00''' '''2 00:59:58''' '''2 01:00:01''' 'ut_utils.tr_success'


