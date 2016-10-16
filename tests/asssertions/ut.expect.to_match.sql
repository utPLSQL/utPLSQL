PROMPT Gives success when varchar2 is matching regex without modifiers
@@asssertions/common/ut.expect.to_match.common.sql 'varchar2(100)' '''Stephen''' '^Ste(v|ph)en$' '' 'ut_utils.tr_success'

PROMPT Gives success when varchar2 is matching regex with modifiers
@@asssertions/common/ut.expect.to_match.common.sql 'varchar2(100)' '''sTEPHEN''' '^Ste(v|ph)en$' 'i' 'ut_utils.tr_success'

PROMPT Gives success when clob is matching regex without modifiers
@@asssertions/common/ut.expect.to_match.common.sql 'clob' 'rpad('' '',32767)||''Stephen''' 'Ste(v|ph)en$' '' 'ut_utils.tr_success'

PROMPT Gives success when clob is matching regex with modifiers
@@asssertions/common/ut.expect.to_match.common.sql 'clob' 'rpad('' '',32767)||''sTEPHEN''' 'Ste(v|ph)en$' 'i' 'ut_utils.tr_success'

PROMPT Gives failure when varchar2 is not matching regex without modifiers
@@asssertions/common/ut.expect.to_match.common.sql 'varchar2(100)' '''Stephen''' '^Steven$' '' 'ut_utils.tr_failure'

PROMPT Gives failure when varchar2 is not matching regex with modifiers
@@asssertions/common/ut.expect.to_match.common.sql 'varchar2(100)' '''sTEPHEN''' '^Steven$' 'i' 'ut_utils.tr_failure'

PROMPT Gives failure when clob is not matching regex without modifiers
@@asssertions/common/ut.expect.to_match.common.sql 'clob' 'rpad('' '',32767)||''Stephen''' '^Stephen' '' 'ut_utils.tr_failure'

PROMPT Gives failure when clob is not matching regex with modifiers
@@asssertions/common/ut.expect.to_match.common.sql 'clob' 'rpad('' '',32767)||''sTEPHEN''' '^Stephen' 'i' 'ut_utils.tr_failure'
