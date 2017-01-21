PROMPT Run user examples
Clear Screen
--set echo off
--set feedback off
set linesize 1000

prompt Common examples from web

exec ut_documentation_reporter.set_color_enabled(true);
@@award_bonus/run_award_bonus_test.sql

@@between_string/run_betwnstr_test.sql

@@remove_rooms_by_name/run_remove_rooms_by_name_test.sql

@@demo_of_expectations/run.sql

prompt Additional examples
prompt RunExampleTestAnnotationBasedForCurrentSchema
@@RunExampleTestAnnotationBasedForCurrentSchema.sql
prompt RunExpectations
@@RunExpectations.sql

@@RunWithDocumentationReporter.sql
