create or replace package ut_annotation_manager authid current_user as
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
   * Builds annotations out of database source code by reading it from cache
   */

  /**
   * Gets annotations for all objects of a specified type for database schema.
   * Annotations that are stale or missing are parsed and placed in persistent cache.
   * After placing in cache, annotation data is returned as pipelined table data.
   *
   * @param a_object_owner owner of objects to get annotations for
   * @param a_object_type type of objects to get annotations for
   * @param a_parse_date   date when object was last parsed
   * @return array containing annotated objects along with annotations for each object (nested)
   */
  function get_annotated_objects(a_object_owner varchar2, a_object_type varchar2, a_parse_date timestamp := null) return ut_annotated_objects pipelined;

  /**
   * Rebuilds annotation cache for a specified schema and object type.
   *  The procedure is called internally by `get_annotated_objects` function.
   *  It can be used to speedup initial execution of utPLSQL on a given schema
   *   if it is executed before any call is made to `ut.run` or `ut_runner.run` procedure.
   *
   * @param a_object_owner owner of objects to get annotations for
   * @param a_object_type type of objects to get annotations for
   */
  procedure rebuild_annotation_cache(a_object_owner varchar2, a_object_type varchar2);

  /**
   * Removes cached information about annotations for objects of specified type and specified owner
   *
   * @param a_object_owner owner of objects to purge annotations for
   * @param a_object_type type of objects to purge annotations for
   */
  procedure purge_cache(a_object_owner varchar2, a_object_type varchar2);

  
  function hash_suite_path(a_path varchar2, a_random_seed positiven) return varchar2;

end ut_annotation_manager;
/
