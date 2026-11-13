create or replace noneditionable package ut_annotation_cache_macros authid definer as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2026 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  /*
   * SQL macros over the annotation cache tables.
   *
   * A package containing SQL macros cannot be an invoker rights package, so the macros are kept apart from ut_annotation_cache_manager.
   * A macro only returns SQL text. The text is expanded into the calling SQL statement and runs with the privileges of the caller,
   * so the macros can only be used by framework code that has the <framework owner>_cbac_modify_objects_role.
   * Callers reference the macros qualified with the framework owner, as unqualified names in invoker rights SQL resolve in the invoker's schema.
   * The owner is filled in by the SQL*Plus substitution variable ut3_owner when the package body is installed by install.sql.
   */

  /**
   * Table SQL macro returning objects stored in annotation cache
   * Columns: object_owner, object_name, object_type, parse_time
   *
   * @param a_object_owner owner of cached objects
   * @param a_object_type  type of cached objects
   */
  function get_cached_objects(a_object_owner varchar2, a_object_type varchar2) return varchar2 sql_macro;

end;
/
