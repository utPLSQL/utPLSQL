create or replace type ut_cursor_column authid current_user as object (
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
   parent_name      varchar2(4000),
   access_path      varchar2(4000),
   filter_path      varchar2(4000),
   display_path     varchar2(4000),
   has_nested_col   number(1,0),
   transformed_name varchar2(2000),
   hierarchy_level  number,
   column_position  number,
   xml_valid_name   varchar2(2000),
   column_name      varchar2(2000),
   column_type      varchar2(128),
   column_type_name varchar2(128),
   column_schema    varchar2(128),
   column_len       integer,
   column_precision integer,
   column_scale     integer,
   is_sql_diffable  number(1, 0),
   is_collection    number(1, 0),

   member procedure init(self in out nocopy ut_cursor_column,
     a_col_name varchar2, a_col_schema_name varchar2,
     a_col_type_name varchar2, a_col_max_len integer, a_parent_name varchar2 := null, a_hierarchy_level integer := 1,
     a_col_position integer, a_col_type in varchar2, a_collection integer,a_access_path in varchar2, a_col_precision in integer,
     a_col_scale integer),
     
   constructor function ut_cursor_column( self in out nocopy ut_cursor_column,
     a_col_name varchar2, a_col_schema_name varchar2,
     a_col_type_name varchar2, a_col_max_len integer, a_parent_name varchar2 := null, a_hierarchy_level integer := 1,
     a_col_position integer, a_col_type in varchar2, a_collection integer, a_access_path in varchar2, a_col_precision in integer,
     a_col_scale integer)
   return self as result,
   
  constructor function ut_cursor_column( self in out nocopy ut_cursor_column) return self as result
)
/
