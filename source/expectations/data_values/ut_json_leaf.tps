create or replace type ut_json_leaf force authid current_user as object (
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
   element_name     varchar2(4000),
   element_value    varchar2(4000),
   parent_name      varchar2(4000),
   access_path      varchar2(4000),
   tlength          integer,
   display_path     varchar2(4000),
   hierarchy_level  integer,
   index_position   integer,
   json_type        varchar2(2000),
   is_array_element integer,
   parent_type      varchar2(2000),

   member procedure init(self in out nocopy ut_json_leaf,
     a_element_name varchar2, a_element_value varchar2,a_parent_name varchar2, 
     a_access_path varchar2, a_hierarchy_level integer, a_index_position integer, a_json_type in varchar2,
     a_parent_type varchar2, a_array_element integer:=0),
     
   constructor function ut_json_leaf( self in out nocopy ut_json_leaf,
     a_element_name varchar2, a_element_value varchar2,a_parent_name varchar2,
     a_access_path varchar2, a_hierarchy_level integer, a_index_position integer, a_json_type in varchar2,
     a_parent_type varchar2, a_array_element integer:=0)
   return self as result
)
/
