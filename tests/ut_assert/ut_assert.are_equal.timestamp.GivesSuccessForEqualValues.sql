PROMPT Gives a success when comparing equal timestamp datatypes

@@ut_assert/common/ut_assert.are_equal.scalar.common.sql 'timestamp(9)' 'to_Timestamp(''2016-09-06 22:36:11.123456789'',''yyyy-mm-dd hh24:mi:ss.xff'')' 'to_Timestamp(''2016-09-06 22:36:11.123456789'',''yyyy-mm-dd hh24:mi:ss.xff'')' 'ut_utils.tr_success'
