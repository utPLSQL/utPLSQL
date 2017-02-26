@@lib/RunTest.sql "ut_utils/common/ut_utils.clob_to_table.sql 'a,b,c,d' ',' ut_varchar2_list('a','b','c','d') 1000"
@@lib/RunTest.sql "ut_utils/common/ut_utils.clob_to_table.sql '' ',' ut_varchar2_list() 1000"
@@lib/RunTest.sql "ut_utils/common/ut_utils.clob_to_table.sql '1,b,c,d' '' ut_varchar2_list('1,b,','c,d') 4"
@@lib/RunTest.sql "ut_utils/common/ut_utils.clob_to_table.sql 'abcdefg,hijk,axa,a' ',' ut_varchar2_list('abc','def','g','hij','k','axa','a') 3"
@@lib/RunTest.sql "ut_utils/common/ut_utils.clob_to_table.sql ',a,,c,d,' ',' ut_varchar2_list('','a','','c','d','') 1000"


