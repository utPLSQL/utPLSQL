create or replace package body ut_session_context as
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
  $IF $$SELF_TESTING_INSTALL $THEN
  gc_context_name constant varchar2(30) := ut_utils.ut_owner()||'_INFO';
  $ELSE
  gc_context_name constant varchar2(30) := 'UT3_INFO';
  $END

  procedure set_context(a_name varchar2, a_value varchar2) is
  begin
    dbms_session.set_context( gc_context_name, a_name, a_value );
  end;

  procedure clear_context(a_name varchar2) is
  begin
    dbms_session.clear_context( namespace => gc_context_name, attribute => a_name );
  end;

  procedure clear_all_context is
  begin
    dbms_session.clear_all_context( namespace => gc_context_name );
  end;

  function is_ut_run return boolean is
    l_paths    varchar2(32767);
  begin
    l_paths := sys_context(gc_context_name, 'RUN_PATHS');
    return l_paths is not null;
  end;

  function get_namespace return varchar2 is
  begin
    return gc_context_name;
  end;

end;
/