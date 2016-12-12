set echo off
set feedback off
set verify off
set linesize 5000
set pagesize 0
set serveroutput on size unlimited format truncated
@@lib/RunVars.sql

@@TestCore.sql

--Finally
@@lib/RunSummary
--can be used by CI to check for tests status
exit :failures_count
