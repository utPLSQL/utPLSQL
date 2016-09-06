PROMPT Gives a failure when expected is non null timestamp and actual is null

@@ut_assert/common/ut_assert.are_equal.scalar.common.sql 'timestamp(9)' 'systimestamp' 'null' 'ut_utils.tr_failure'
