PROMPT Gives success when varchar2 is matching pattern without escape char
@@asssertions/common/ut.expect.to_be_like.common.sql 'varchar2(100)' '''Stephen_King''' 'Ste__en%' '' 'ut_utils.tr_success'

PROMPT Gives success when varchar2 is matching pattern with escape char
@@asssertions/common/ut.expect.to_be_like.common.sql 'varchar2(100)' '''Stephen_King''' 'Ste__en\_K%' '\' 'ut_utils.tr_success'

PROMPT Gives success when clob is matching pattern without escape char
@@asssertions/common/ut.expect.to_be_like.common.sql 'clob' 'rpad(''a'',32767,''a'')||''Stephen_King''' 'a%Ste__en%' '' 'ut_utils.tr_success'

PROMPT Gives success when clob is matching pattern with escape char
@@asssertions/common/ut.expect.to_be_like.common.sql 'clob' 'rpad(''a'',32767,''a'')||''Stephen_King''' 'a%Ste__en\_K%' '\' 'ut_utils.tr_success'

PROMPT Gives failure when varchar2 is not matching pattern without escape char
@@asssertions/common/ut.expect.to_be_like.common.sql 'varchar2(100)' '''Stephen_King''' 'Ste_en%' '' 'ut_utils.tr_failure'

PROMPT Gives failure when varchar2 is not matching pattern with escape char
@@asssertions/common/ut.expect.to_be_like.common.sql 'varchar2(100)' '''Stephen_King''' 'Stephe\__%' '\' 'ut_utils.tr_failure'

PROMPT Gives failure when clob is not matching pattern without escape char
@@asssertions/common/ut.expect.to_be_like.common.sql 'clob' 'rpad(''a'',32767,''a'')||''Stephen_King''' 'a%Ste_en%' '' 'ut_utils.tr_failure'

PROMPT Gives failure when clob is not matching pattern with escape char
@@asssertions/common/ut.expect.to_be_like.common.sql 'clob' 'rpad(''a'',32767,''a'')||''Stephen_King''' 'a%Stephe\__%' '\' 'ut_utils.tr_failure'

PROMPT Gives failure when trying to use matcher with number datatype
@@asssertions/common/ut.expect.to_be_like.common.sql 'number' '12345' 'a%Stephe\__%' '\' 'ut_utils.tr_failure'
