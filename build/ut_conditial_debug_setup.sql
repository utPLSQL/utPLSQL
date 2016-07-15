--This is only typically needed by developers of utplsql
--Running this script recompiles the packages with tracing turned on.

alter session set PLSQL_Warnings = 'enable:all';
alter session set PLSQL_CCFlags = 'ut_trace:true';

alter package ut_types compile  debug package;
alter package ut_assert compile  debug package;
alter package ut_testexecute compile  debug package;
alter package ut_exampletest compile  debug package;
