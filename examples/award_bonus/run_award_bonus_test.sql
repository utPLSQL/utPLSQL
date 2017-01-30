@@employees_test.sql
@@award_bonus.sql
@@test_award_bonus.pkg

set serveroutput on size unlimited format truncated

exec ut.run(user||'.test_award_bonus');

drop package test_award_bonus;
drop procedure award_bonus;
drop table employees_test;
