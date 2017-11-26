create or replace package ut_metadata authid current_user as
  /*
  utPLSQL - Version X.X.X.X
  Copyright 2016 - 2017 utPLSQL Project

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
   * Common package for all code that reads from the system tables.
   */

  /**
   * Forms correct object/subprogram name to call as owner.object[.subprogram]
   *
   */
  function form_name(a_owner_name varchar2, a_object varchar2, a_subprogram varchar2 default null) return varchar2;

  /**
   * Check if package exists and is in a VALID state
   *
   */
  function package_valid(a_owner_name varchar2, a_package_name in varchar2) return boolean;

  /**
   * Check if package exists and is VALID and contains the given procedure.
   *
   */
  function procedure_exists(a_owner_name varchar2, a_package_name in varchar2, a_procedure_name in varchar2)
    return boolean;

  /**
   * Resolves [owner.]object using dbms_utility.name_resolve and returns resolved parts
   *
   */
  procedure do_resolve(a_owner in out nocopy varchar2, a_object in out nocopy varchar2);

  /**
   * Resolves [owner.]object[.procedure] using dbms_utility.name_resolve and returns resolved parts
   *
   */
  procedure do_resolve(a_owner in out nocopy varchar2, a_object in out nocopy varchar2, a_procedure_name in out nocopy varchar2);

  /**
   * Return the text of the source line for a given object (body). It excludes package spec and type spec
   */
  function get_source_definition_line(a_owner varchar2, a_object_name varchar2, a_line_no integer) return varchar2;


  /**
   * Invalidates package-level cache for source.
   * Caching is used to improve performance of function get_source_definition_line
   */
  procedure reset_source_definition_cache;

  /**
   * Returns dba_... view name if it is accessible, otherwise it returns all_xxx view
   * @param a_dba_view_name the name of dba view requested
   */
  function get_dba_view(a_dba_view_name varchar2) return varchar2;

  /**
   * Returns true if given object is a package and it exists in current schema
   * @param a_object_name the name of the object to be checked
   */
  function package_exists_in_cur_schema(a_object_name varchar2) return boolean;

end ut_metadata;
/
