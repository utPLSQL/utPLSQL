PROMPT Gives a failure when comparing different timestamp datatypes

@@ut_assert/common/ut_assert.are_equal.scalar.common.sql 'timestamp(9)' 'to_Timestamp(''2016-09-06 22:36:11.123456789'',''yyyy-mm-dd hh24:mi:ss.ff'')' 'to_Timestamp(''2016-09-06 22:36:11.123456788'',''yyyy-mm-dd hh24:mi:ss.ff'')' 'ut_utils.tr_failure'
