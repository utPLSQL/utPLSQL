@@lib/RunTest.sql "ut_utils/common/ut_utils.table_to_clob.sql "cast(null as ut_varchar2_list)"       ''',''' ''''''"
@@lib/RunTest.sql "ut_utils/common/ut_utils.table_to_clob.sql ut_varchar2_list()                     ''',''' ''''''"
@@lib/RunTest.sql "ut_utils/common/ut_utils.table_to_clob.sql ut_varchar2_list('a','b','c','d')      ''',''' '''a,b,c,d''' "
@@lib/RunTest.sql "ut_utils/common/ut_utils.table_to_clob.sql ut_varchar2_list('1,b,','c,d')         ''',''' '''1,b,,c,d'''"
@@lib/RunTest.sql "ut_utils/common/ut_utils.table_to_clob.sql ut_varchar2_list('','a','','c','d','') ''',''' ''',a,,c,d,'''"


