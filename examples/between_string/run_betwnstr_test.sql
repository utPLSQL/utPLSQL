@@betwnstr.sql
@@test_betwnstr.pks
@@test_betwnstr.pkb

set serveroutput on size unlimited format truncated

exec ut.run(user||'.test_betwnstr');

drop package test_betwnstr;
drop function betwnstr;

