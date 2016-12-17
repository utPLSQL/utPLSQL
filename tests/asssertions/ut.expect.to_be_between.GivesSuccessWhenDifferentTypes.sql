PROMPT Gives success when expected are numbers and and actual is varchar
@@asssertions/common/ut.expect.to_be_between.scalar.different_types.common.sql 'varchar2(4000)' 'number' '''1''' '0' '2' 'ut_utils.tr_success'

PROMPT Gives success when expected are varchars and and actual is number
@@asssertions/common/ut.expect.to_be_between.scalar.different_types.common.sql 'number' 'varchar2(4000)' '1' '''0''' '''2''' 'ut_utils.tr_success'
