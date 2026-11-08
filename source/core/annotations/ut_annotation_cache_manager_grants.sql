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

  Code based access control for the invoker rights package ut_annotation_cache_manager.
  The package accesses the annotation cache tables through the role <framework owner>_cbac_modify_objects_role,
  so the users calling the framework do not need any privileges on those tables.
  The types are constructed in SQL statements of the package, so the role needs to be able to execute them too.
  This way the types do not need to be granted to the users calling the framework.
*/
grant select, insert, update, delete on &&ut3_owner..ut_annotation_cache        to &&ut3_owner._cbac_modify_objects_role;
grant select, insert, update, delete on &&ut3_owner..ut_annotation_cache_info   to &&ut3_owner._cbac_modify_objects_role;
grant select, insert, update, delete on &&ut3_owner..ut_annotation_cache_schema to &&ut3_owner._cbac_modify_objects_role;
grant select                         on &&ut3_owner..ut_annotation_cache_seq    to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_annotation_obj_cache_info to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_annotated_object          to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_annotation                to &&ut3_owner._cbac_modify_objects_role;
grant execute on &&ut3_owner..ut_annotations               to &&ut3_owner._cbac_modify_objects_role;

grant &&ut3_owner._cbac_modify_objects_role to package &&ut3_owner..ut_annotation_cache_manager;
--granting a role to a package invalidates the package
alter package &&ut3_owner..ut_annotation_cache_manager compile;
