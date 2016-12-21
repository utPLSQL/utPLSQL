PROMPT Greater than

@@ut_expectations/common/ut.expect.common.be_greater_than.sql 'date' 'sysdate' 'sysdate-1' 'ut_utils.tr_success'
@@ut_expectations/common/ut.expect.common.be_greater_than.sql 'number' '2.0' '1.99' 'ut_utils.tr_success'
@@ut_expectations/common/ut.expect.common.be_greater_than.sql 'interval year to month' '''2-1''' '''2-0''' 'ut_utils.tr_success'
@@ut_expectations/common/ut.expect.common.be_greater_than.sql 'interval day to second' '''2 01:00:00''' '''2 00:59:59''' 'ut_utils.tr_success'
@@ut_expectations/common/ut.expect.common.be_greater_than.sql 'timestamp' 'to_timestamp(''1997-01-31 09:26:50.13'',''YYYY-MM-DD HH24.MI.SSXFF'')' 'to_timestamp(''1997-01-31 09:26:50.12'',''YYYY-MM-DD HH24.MI.SSXFF'')' 'ut_utils.tr_success'
@@ut_expectations/common/ut.expect.common.be_greater_than.sql 'timestamp with time zone' 'to_timestamp_tz(''1997-01-31 09:26:50.12 +01:00'',''YYYY-MM-DD HH24.MI.SSXFF TZR'')' 'to_timestamp_tz(''1997-01-31 09:26:50.12 +02:00'',''YYYY-MM-DD HH24.MI.SSXFF TZR'')' 'ut_utils.tr_success'
@@ut_expectations/common/ut.expect.common.be_greater_than.sql 'timestamp with local time zone' 'to_timestamp_tz(''1997-01-31 09:26:50.12 +01:00'',''YYYY-MM-DD HH24.MI.SSXFF TZR'')' 'to_timestamp_tz(''1997-01-31 09:26:50.12 +02:00'',''YYYY-MM-DD HH24.MI.SSXFF TZR'')' 'ut_utils.tr_success'

@@ut_expectations/common/ut.expect.common.be_greater_than.sql 'date' 'sysdate-1' 'sysdate' 'ut_utils.tr_failure'
@@ut_expectations/common/ut.expect.common.be_greater_than.sql 'number' '1.0' '1.01' 'ut_utils.tr_failure'
@@ut_expectations/common/ut.expect.common.be_greater_than.sql 'interval year to month' '''2-1''' '''2-2''' 'ut_utils.tr_failure'
@@ut_expectations/common/ut.expect.common.be_greater_than.sql 'interval day to second' '''2 00:59:58''' '''2 00:59:59''' 'ut_utils.tr_failure'
@@ut_expectations/common/ut.expect.common.be_greater_than.sql 'timestamp' 'to_timestamp(''1997-01-31 09:26:50.12'',''YYYY-MM-DD HH24.MI.SSXFF'')' 'to_timestamp(''1997-01-31 09:26:50.13'',''YYYY-MM-DD HH24.MI.SSXFF'')' 'ut_utils.tr_failure'
@@ut_expectations/common/ut.expect.common.be_greater_than.sql 'timestamp with time zone' 'to_timestamp_tz(''1997-01-31 09:26:50.12 +03:00'',''YYYY-MM-DD HH24.MI.SSXFF TZR'')' 'to_timestamp_tz(''1997-01-31 09:26:50.12 +02:00'',''YYYY-MM-DD HH24.MI.SSXFF TZR'')' 'ut_utils.tr_failure'
@@ut_expectations/common/ut.expect.common.be_greater_than.sql 'timestamp with local time zone' 'to_timestamp_tz(''1997-01-31 09:26:50.12 +03:00'',''YYYY-MM-DD HH24.MI.SSXFF TZR'')' 'to_timestamp_tz(''1997-01-31 09:26:50.12 +02:00'',''YYYY-MM-DD HH24.MI.SSXFF TZR'')' 'ut_utils.tr_failure'
