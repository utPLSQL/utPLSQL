/*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
@@define_ut3_owner_param.sql

set feedback on

spool uninstall.log

prompt &&line_separator
prompt Uninstalling UTPLSQL v3 framework
prompt &&line_separator

alter session set current_schema = &&ut3_owner;

@@uninstall_objects.sql

@@uninstall_synonyms.sql

begin
  dbms_output.put_line('&&line_separator');
  dbms_output.put_line('Uninstall complete');
  dbms_output.put_line('&&line_separator');
end;
/

spool off

exit;
