PROMPT Gives a failure when expected is non null varchar2 and actual is null

@@ut_assert/common/ut_assert.are_equal.scalar.common.sql 'varchar2(4000)' '''abc''' 'NULL' 'ut_utils.tr_failure'
