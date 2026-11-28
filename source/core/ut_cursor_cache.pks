create or replace noneditionable package ut_cursor_cache authid current_user is
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

  /**
   * Get a cached DBMS_SQL cursor for a repeatedly-executed procedure.
   * Cursors are keyed by executable identity and reused across calls.
   * On execution failure the cursor is closed and evicted from the cache.
   *
   * @return integer - DBMS_SQL cursor number (already parsed)
   */
  function get_cursor(
    a_owner       varchar2,
    a_object      varchar2,
    a_procedure   varchar2
  ) return integer;

  /**
   * Close all cached cursors and clear the cache.
   * Call at the start of each run/suite to avoid stale cursors.
   */
  procedure clear_cache;

end ut_cursor_cache;
/
