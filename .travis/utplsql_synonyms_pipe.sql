whenever sqlerror exit failure rollback
whenever oserror exit failure rollback
set echo off
set feedback on
set heading off
set verify off

define ut3_owner   = "&1"
define ut3_user    = "&2"
define ut3_syntype = "&3"

create &ut3_syntype synonym &ut3_user.ut_output_dbms_pipe           for &ut3_owner..ut_output_dbms_pipe;


exit success

