PROMPT Splits a given string into table of string by delimiter
@@lib/RunTest.sql "ut_utils/common/ut_utils.clob_to_table.sql 'a,b,c,d' ',' ut_varchar2_list('a','b','c','d') 1000"

PROMPT If a_text is null then empty table is returned.
@@lib/RunTest.sql "ut_utils/common/ut_utils.clob_to_table.sql '' ',' ut_varchar2_list() 1000"

PROMPT If a_delimiter is null then data is split by max size.
@@lib/RunTest.sql "ut_utils/common/ut_utils.clob_to_table.sql '1,b,c,d' '' ut_varchar2_list('1,b,','c,d') 4"

PROMPT If split text is longer than a_max_amount it gets split into pieces of a_max_amount
@@lib/RunTest.sql "ut_utils/common/ut_utils.clob_to_table.sql 'abcdefg,hijk,axa,a' ',' ut_varchar2_list('abc','def','g','hij','k','axa','a') 3"

PROMPT If no text between delimiters found then an empty row is returned
@@lib/RunTest.sql "ut_utils/common/ut_utils.clob_to_table.sql ',a,,c,d,' ',' ut_varchar2_list('','a','','c','d','') 1000"


