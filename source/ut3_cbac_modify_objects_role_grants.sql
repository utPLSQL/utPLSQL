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

  Code based access control for the invoker rights packages ut_annotation_cache_manager, ut_annotation_manager and ut_suite_cache_manager.
  The packages access the annotation and suite cache tables through the role <framework owner>_cbac_modify_objects_role,
  directly or through the SQL macros of ut_annotation_cache_macros,
  so the users calling the framework do not need any privileges on those tables.
  The types and packages used in SQL statements of those packages are granted to the role too,
  so they do not need to be granted to the users calling the framework.
*/

prompt Granting privileges to role &&ut3_owner._cbac_modify_objects_role

--annotation cache
grant select, insert, update, delete on &&ut3_owner..ut_annotation_cache        to &&ut3_owner._cbac_modify_objects_role;
grant select, insert, update, delete on &&ut3_owner..ut_annotation_cache_info   to &&ut3_owner._cbac_modify_objects_role;
grant select, insert, update, delete on &&ut3_owner..ut_annotation_cache_schema to &&ut3_owner._cbac_modify_objects_role;
grant select                         on &&ut3_owner..ut_annotation_cache_seq    to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_annotation_obj_cache_info to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_annotated_object          to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_annotation                to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_annotations               to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_annotation_cache_macros   to &&ut3_owner._cbac_modify_objects_role;

--suite cache
grant select, insert, update, delete on &&ut3_owner..ut_suite_cache         to &&ut3_owner._cbac_modify_objects_role;
grant select, insert, update, delete on &&ut3_owner..ut_suite_cache_package to &&ut3_owner._cbac_modify_objects_role;
grant select, insert, update, delete on &&ut3_owner..ut_suite_cache_schema  to &&ut3_owner._cbac_modify_objects_role;
grant select                         on &&ut3_owner..ut_suite_cache_seq     to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_suite_cache_row  to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_suite_item_info  to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_suite            to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_test             to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_executables      to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_executable_test  to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_varchar2_rows    to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_path_item        to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_object_name      to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_utils            to &&ut3_owner._cbac_modify_objects_role;

grant &&ut3_owner._cbac_modify_objects_role to package &&ut3_owner..ut_annotation_cache_manager;
grant &&ut3_owner._cbac_modify_objects_role to package &&ut3_owner..ut_annotation_manager;
grant &&ut3_owner._cbac_modify_objects_role to package &&ut3_owner..ut_suite_cache_manager;

