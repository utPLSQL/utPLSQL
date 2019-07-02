create or replace package ut_session_context as
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

  /*
  * Sets value of a context
  */
  procedure set_context(a_name varchar2, a_value varchar2);

  /*
  * Clears value of a context
  */
  procedure clear_context(a_name varchar2);

  /*
  * Clears entire context for utPLSQL run
  */
  procedure clear_all_context;

  /*
  * Returns true, if session context UT3_INFO is not empty
  */
  function is_ut_run return boolean;
    
  /*
  * Returns utPLSQL session context namespace name
  */
  function get_namespace return varchar2;

end;
/