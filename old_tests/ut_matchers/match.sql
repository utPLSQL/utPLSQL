@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_match.common.sql 'varchar2(100)' '''Stephen''' '^Ste(v|ph)en$' '' 'ut_utils.tr_success' ''"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_match.common.sql 'varchar2(100)' '''sTEPHEN''' '^Ste(v|ph)en$' 'i' 'ut_utils.tr_success' ''"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_match.common.sql 'clob' 'rpad('' '',32767)||''Stephen''' 'Ste(v|ph)en$' '' 'ut_utils.tr_success' ''"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_match.common.sql 'clob' 'rpad('' '',32767)||''sTEPHEN''' 'Ste(v|ph)en$' 'i' 'ut_utils.tr_success' ''"

@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_match.common.sql 'varchar2(100)' '''Stephen''' '^Steven$' '' 'ut_utils.tr_failure' ''"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_match.common.sql 'varchar2(100)' '''sTEPHEN''' '^Steven$' 'i' 'ut_utils.tr_failure' ''"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_match.common.sql 'clob' 'to_clob(rpad('' '',32767)||''Stephen'')' '^Stephen' '' 'ut_utils.tr_failure' ''"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_match.common.sql 'clob' 'to_clob(rpad('' '',32767)||''sTEPHEN'')' '^Stephen' 'i' 'ut_utils.tr_failure' ''"

@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_match.common.sql 'varchar2(100)' '''Stephen''' '^Ste(v|ph)en$' '' 'ut_utils.tr_failure' 'not_'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_match.common.sql 'varchar2(100)' '''sTEPHEN''' '^Ste(v|ph)en$' 'i' 'ut_utils.tr_failure' 'not_'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_match.common.sql 'clob' 'rpad('' '',32767)||''Stephen''' 'Ste(v|ph)en$' '' 'ut_utils.tr_failure' 'not_'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_match.common.sql 'clob' 'rpad('' '',32767)||''sTEPHEN''' 'Ste(v|ph)en$' 'i' 'ut_utils.tr_failure' 'not_'"

@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_match.common.sql 'varchar2(100)' '''Stephen''' '^Steven$' '' 'ut_utils.tr_success' 'not_'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_match.common.sql 'varchar2(100)' '''sTEPHEN''' '^Steven$' 'i' 'ut_utils.tr_success' 'not_'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_match.common.sql 'clob' 'to_clob(rpad('' '',32767)||''Stephen'')' '^Stephen' '' 'ut_utils.tr_success' 'not_'"
@@lib/RunTest.sql "ut_matchers/common/ut.expect.to_match.common.sql 'clob' 'to_clob(rpad('' '',32767)||''sTEPHEN'')' '^Stephen' 'i' 'ut_utils.tr_success' 'not_'"
