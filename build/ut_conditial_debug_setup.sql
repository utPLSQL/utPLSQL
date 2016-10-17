--This is only typically needed by developers of utplsql
--Running this script recompiles the packages with tracing turned on.

alter session set PLSQL_Warnings = 'enable:all';
alter session set PLSQL_CCFlags = 'ut_trace:true';

alter package ut_annotations compile  debug package;
alter package ut_suite_manager compile  debug package;
alter package ut_utils compile  debug package;
