set echo off
set feedback off
set verify off
set linesize 5000
set pagesize 0
set serveroutput on size unlimited format truncated
@@lib/RunVars.sql

define ut3_runuser       = "&1"
define ut3_runpass       = "&2"

--Global setup

--Tests to invoke
@@TestCore.sql
@@TestExt_pipe.sql

--Global cleanup

--Finally
@@lib/RunSummary
--can be used by CI to check for tests status
exit :failures_count
