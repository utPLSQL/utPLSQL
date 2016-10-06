PROMPT Gives a failure when comparing different blob values

@@asssertions/common/ut.expect.to_equal.scalar.common.sql 'blob' 'to_blob(''abc'')' 'to_blob(''abd'')' 'ut_utils.tr_failure'
