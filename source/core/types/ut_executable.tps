create or replace type ut_executable under ut_event_item(
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
  /**
  * The name of the event to be executed before and after the executable is invoked
  */
  executable_type       varchar2(250 char),
  owner_name            varchar2(250 char),
  object_name           varchar2(250 char),
  procedure_name        varchar2(250 char),
  error_backtrace       varchar2(4000),
  error_stack           varchar2(4000),
  serveroutput          clob,
  /**
  * Used for ordering of executables, as Oracle doesn not guarantee ordering of items in a nested table.
  */
  seq_no                integer,
	constructor function ut_executable( self in out nocopy ut_executable, a_owner varchar2, a_package varchar2, a_procedure_name varchar2, a_executable_type varchar2) return self as result,
  member function form_name(a_skip_current_user_schema boolean := false) return varchar2,
  member procedure do_execute(self in out nocopy ut_executable, a_item in out nocopy ut_suite_item),
  /**
  * executes the defines executable
  * returns true if executed without exceptions
  * returns false if exceptions were raised
  */
  member function do_execute(self in out nocopy ut_executable, a_item in out nocopy ut_suite_item) return boolean,
  member function get_error_stack_trace return varchar2
) not final
/
