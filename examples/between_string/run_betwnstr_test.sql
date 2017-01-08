@@betwnstr.sql
@@test_betwnstr.pkg

set serveroutput on size unlimited format truncated

exec ut_runner.run(user||'.test_betwnstr');

drop package test_betwnstr;
drop function betwnstr;

