PROMPT Run user examples
set echo on
set feedback on
set linesize 1000

prompt Common examples from web

set pagesize 0
column owner format a30
column synonym_name format a30
column table_owner format a30
select owner, synonym_name, table_owner from all_synonyms where synonym_name like 'UT%';

exec ut_ansiconsole_helper.color_enabled(true);
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
