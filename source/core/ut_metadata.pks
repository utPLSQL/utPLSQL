create or replace package ut_metadata authid current_user as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2018 utPLSQL Project

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

  type t_anytype_members_rec is record (
    type_code       pls_integer,
    schema_name     varchar2(128),
    type_name       varchar2(128),
    length          pls_integer,
    elements_count  pls_integer,
    version         varchar2(32767),
    precision       pls_integer,
    scale           pls_integer,
    char_set_id     pls_integer,
    char_set_frm    pls_integer
    );

  type t_anytype_elem_info_rec is record (
    type_code       pls_integer,
    attribute_name  varchar2(260),
    length          pls_integer,
    version         varchar2(32767),
    precision       pls_integer,
    scale           pls_integer,
    char_set_id     pls_integer,
    char_set_frm    pls_integer,
    attr_elt_type   anytype
    );

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
   * Resolves [owner.]object[.procedure] using dbms_utility.name_resolve and returns resolved parts
   *
   */
  procedure do_resolve(a_owner in out nocopy varchar2, a_object in out nocopy varchar2, a_procedure_name in out nocopy varchar2);

  /**
   * Resolves single string [owner.]object[.procedure] using dbms_utility.name_resolve and returns parts [owner] [object] [procedure]
   */
  procedure do_resolve(a_fully_qualified_name in varchar2,a_context in integer,a_owner out nocopy varchar2, 
    a_object out nocopy varchar2, a_procedure_name out nocopy varchar2);

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
   * Returns dba_... view name if it is accessible, otherwise it returns all_... view
   * @param a_dba_view_name the name of dba view requested
   */
  function get_dba_view(a_dba_view_name varchar2) return varchar2;

  /**
   * Returns dba_source if accessible otherwise returns all_source
   */
  function get_source_view_name return varchar2;

  /**
   * Returns dba_objects if accessible otherwise returns all_objects
   */
  function get_objects_view_name return varchar2;

  /**
   * Returns true if object is accessible to current user
   * @param a_object_name fully qualified object name (with schema name)
   */
  function is_object_visible(a_object_name varchar2) return boolean;

  /**
   * Returns true if current user has execute any procedure privilege
   * The check is performed by checking if user can execute ut_utils package
   */
  function user_has_execute_any_proc return boolean;

  /**
   * Returns true if given object is a package and it exists in current schema
   * @param a_object_name the name of the object to be checked
   */
  function package_exists_in_cur_schema(a_object_name varchar2) return boolean;

  /**
  * Returns true if given typecode is a collection typecode
  */
  function is_collection(a_anytype_code in integer) return boolean;

  /**
  * Returns true if given object is a collection
  */
  function is_collection(a_owner varchar2, a_type_name varchar2) return boolean;

  /**
  * Returns a descriptor of anytype
  */
  function get_anytype_members_info( a_anytype anytype ) return t_anytype_members_rec;

  /**
  * Returns a descriptor of anytype attribute
  */
  function get_attr_elem_info( a_anytype anytype, a_pos pls_integer := null ) return t_anytype_elem_info_rec;

  /**
  * Returns ANYTYPE descriptor of an object type
  */
  function get_user_defined_type(a_owner varchar2, a_type_name varchar2) return anytype;
  
  /**
  * Return fully qualified name of the object from collection, if not collection returns null
  */
  function get_collection_element(a_anydata in anydata) return varchar2;

  /**
  * Check if collection got elements
  */  
  function has_collection_members (a_anydata in anydata) return boolean;

  /**
  * Get typename from anydata
  */   
  function get_anydata_typename(a_data_value anydata) return varchar2;

  /**
  * Is anydata object/collection is null
  */     
  function is_anytype_null(a_value in anydata, a_compound_type in varchar2) return number;
  
end ut_metadata;
/
