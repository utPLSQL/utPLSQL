create or replace package ut_annotation_cache_manager authid definer as
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
   * Populates cache with information about object and it's annotations
   * Cache information for individual object is modified by this code
   * We do not pass a collection here to avoid excessive memory usage
   * when dealing with large number of objects
   *
   * @param a_object a `ut_annotated_object` containing object name, type, owner and `ut_annotations`
   */
  procedure update_cache(a_object ut_annotated_object);

  /**
   * Returns a ref_cursor containing `ut_annotated_object` as result
   * Range of data returned is limited by the input collection o cache object info
   *
   * @param a_cached_objects a `ut_annotation_objs_cache_info` list with information about objects to get from cache
   */
  function get_annotations_for_objects(a_cached_objects ut_annotation_objs_cache_info, a_parse_time timestamp) return sys_refcursor;

  /**
   * Removes cached information about annotations for objects on the list and updates parse_time in cache info table.
   *
   * @param a_objects a `ut_annotation_objs_cache_info` list with information about objects to remove annotations for
   */
  procedure cleanup_cache(a_objects ut_annotation_objs_cache_info);

  /**
   * Removes information about objects on the list
   *
   * @param a_objects a `ut_annotation_objs_cache_info` list with information about objects to remove from cache
   */
  procedure remove_from_cache(a_objects ut_annotation_objs_cache_info);

  /**
   * Removes cached information about annotations for objects of specified type and specified owner
   *
   * @param a_object_owner owner of objects to purge annotations for
   * @param a_object_type type of objects to purge annotations for
   */
  procedure purge_cache(a_object_owner varchar2, a_object_type varchar2);

end;
/
