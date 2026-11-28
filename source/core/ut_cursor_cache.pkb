create or replace noneditionable package body ut_cursor_cache is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2026 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License").
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  type t_cursor_cache is table of integer index by varchar2(1000);
  g_cursor_cache t_cursor_cache;

  function get_cursor(
    a_owner       varchar2,
    a_object      varchar2,
    a_procedure   varchar2
  ) return integer is
    l_identity    varchar2(1000);
    l_cursor      integer;
    l_stmt        varchar2(4000);
  begin
    -- Build cache identity from executable components
    l_identity := nvl(a_owner, '') || '.' || nvl(a_object, '') || '.' || a_procedure;

    -- Reuse cached cursor if available
    if g_cursor_cache.exists(l_identity) then
      return g_cursor_cache(l_identity);
    end if;

    -- Parse once, cache for repeated execution
    l_cursor := dbms_sql.open_cursor;
    l_stmt := 'begin ' ||
      ut_metadata.form_name(a_owner, a_object, a_procedure) ||
      '; end;';
    dbms_sql.parse(l_cursor, l_stmt, dbms_sql.native);
    g_cursor_cache(l_identity) := l_cursor;
    return l_cursor;
  end;

  procedure clear_cache is
    l_cursor integer;
  begin
    for i in 1 .. g_cursor_cache.count loop
      l_cursor := g_cursor_cache(i);
      begin
        dbms_sql.close_cursor(l_cursor);
      exception when others then null; end;
    end loop;
    g_cursor_cache.delete;
  end;

end ut_cursor_cache;
/
