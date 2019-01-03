create or replace type ut_cursor_details force authid current_user as object (
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
   cursor_columns_info      ut_cursor_column_tab,
   is_column_order_enforced number(1,0),

   constructor function ut_cursor_details(self in out nocopy ut_cursor_details) return self as result,
   constructor function ut_cursor_details(
     self in out nocopy ut_cursor_details,a_cursor_number in number
   ) return self as result,
   order member function compare(a_other ut_cursor_details) return integer,
   member procedure desc_compound_data(
     self in out nocopy ut_cursor_details, a_compound_data anytype,
     a_parent_name in varchar2, a_level in integer, a_access_path in varchar2
   ),
   member function get_user_defined_type(a_owner varchar2, a_type_name varchar2) return anytype,
   member function is_collection(a_anytype_code in integer) return boolean,
   member function is_collection(a_owner varchar2, a_type_name varchar2) return boolean,
   member procedure ordered_columns(self in out nocopy ut_cursor_details, a_ordered_columns boolean := false)
)
/
