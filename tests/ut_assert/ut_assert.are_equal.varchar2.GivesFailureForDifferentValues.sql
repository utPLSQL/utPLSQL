PROMPT Gives a failure when comparing different varchar datatypes

@@ut_assert/common/ut_assert.are_equal.scalar.common.sql 'varchar2(4000)' '''abc''' '''ABC''' 'ut_utils.tr_failure'
