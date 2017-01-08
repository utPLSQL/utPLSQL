@@demo_equal_matcher.sql

set serveroutput on size unlimited format truncated

exec ut_runner.run(user||'.demo_equal_matcher');

drop package demo_equal_matcher;
drop type demo_departments;
drop type demo_department_new;
drop type demo_department;

