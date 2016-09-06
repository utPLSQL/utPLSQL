PROMPT Gives a failure when comparing different date datatypes

@@ut_assert/common/ut_assert.are_equal.scalar.common.sql 'date' 'sysdate' 'sysdate+1' 'ut_utils.tr_failure'
