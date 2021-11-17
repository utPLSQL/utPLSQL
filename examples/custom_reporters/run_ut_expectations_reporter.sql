prompt *******************************************************************************
prompt Runnign tests with UT_CUSTOM_REPORTER on top of UT_DOCUMENTATION_REPROTER
prompt *******************************************************************************

set echo off
--install the example unit test packages
@demo_of_expectations/demo_equal_matcher.sql
@@ut_expectations_reporter.tps
@@ut_expectations_reporter.tpb

set serveroutput on size unlimited format truncated

exec ut.run('demo_equal_matcher', ut_expectations_reporter());

@demo_of_expectations/drop_demo_equal_matcher.sql
drop type ut_expectations_reporter;
