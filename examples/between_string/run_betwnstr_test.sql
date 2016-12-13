@@betwnstr.sql
@@test_betwnstr.pkg

set serveroutput on size unlimited format truncated

exec ut.run(user||'.test_betwnstr',ut_documentation_reporter());

drop package test_betwnstr;
drop function betwnstr;

