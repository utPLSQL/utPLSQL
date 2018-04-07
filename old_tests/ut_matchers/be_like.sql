@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_be_like.common.sql 'varchar2(100)' '''Stephen_King''' 'Ste__en%' '' 'ut_utils.gc_success' ''"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_be_like.common.sql 'varchar2(100)' '''Stephen_King''' 'Ste__en\_K%' '\' 'ut_utils.gc_success' ''"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_be_like.common.sql 'clob' 'rpad(''a'',32767,''a'')||''Stephen_King''' 'a%Ste__en%' '' 'ut_utils.gc_success' ''"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_be_like.common.sql 'clob' 'rpad(''a'',32767,''a'')||''Stephen_King''' 'a%Ste__en\_K%' '\' 'ut_utils.gc_success' ''"

@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_be_like.common.sql 'varchar2(100)' '''Stephen_King''' 'Ste_en%' '' 'ut_utils.gc_failure' ''"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_be_like.common.sql 'varchar2(100)' '''Stephen_King''' 'Stephe\__%' '\' 'ut_utils.gc_failure' ''"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_be_like.common.sql 'clob' 'rpad(''a'',32767,''a'')||''Stephen_King''' 'a%Ste_en%' '' 'ut_utils.gc_failure' ''"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_be_like.common.sql 'clob' 'rpad(''a'',32767,''a'')||''Stephen_King''' 'a%Stephe\__%' '\' 'ut_utils.gc_failure' ''"

@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_be_like.common.sql 'varchar2(100)' '''Stephen_King''' 'Ste__en%' '' 'ut_utils.gc_failure' 'not_'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_be_like.common.sql 'varchar2(100)' '''Stephen_King''' 'Ste__en\_K%' '\' 'ut_utils.gc_failure' 'not_'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_be_like.common.sql 'clob' 'rpad(''a'',32767,''a'')||''Stephen_King''' 'a%Ste__en%' '' 'ut_utils.gc_failure' 'not_'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_be_like.common.sql 'clob' 'rpad(''a'',32767,''a'')||''Stephen_King''' 'a%Ste__en\_K%' '\' 'ut_utils.gc_failure' 'not_'"

@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_be_like.common.sql 'varchar2(100)' '''Stephen_King''' 'Ste_en%' '' 'ut_utils.gc_success' 'not_'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_be_like.common.sql 'varchar2(100)' '''Stephen_King''' 'Stephe\__%' '\' 'ut_utils.gc_success' 'not_'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_be_like.common.sql 'clob' 'rpad(''a'',32767,''a'')||''Stephen_King''' 'a%Ste_en%' '' 'ut_utils.gc_success' 'not_'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_be_like.common.sql 'clob' 'rpad(''a'',32767,''a'')||''Stephen_King''' 'a%Stephe\__%' '\' 'ut_utils.gc_success' 'not_'"
