create or replace noneditionable package body ut_annotation_cache_macros as
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

  function get_cached_objects(a_object_owner varchar2, a_object_type varchar2) return varchar2 sql_macro is
  begin
    return q'[
      select /*+ NO_UNNEST NO_EXPAND */ i.object_owner, i.object_name, i.object_type, i.parse_time
        from &&ut3_owner..ut_annotation_cache_info i
       where i.object_owner = a_object_owner
         and i.object_type  = a_object_type]';
  end;

end;
/
