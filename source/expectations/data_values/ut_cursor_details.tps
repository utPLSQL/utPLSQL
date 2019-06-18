create or replace type ut_cursor_details authid current_user as object (
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

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

   /*if type is anydata we need to skip level 1 on joinby / inlude / exclude as its artificial cursor*/
   is_anydata           number(1,0),
   constructor function ut_cursor_details(self in out nocopy ut_cursor_details) return self as result,
   constructor function ut_cursor_details(
     self in out nocopy ut_cursor_details,a_cursor_number in number
   ) return self as result,
   member function equals(a_other ut_cursor_details, a_match_options ut_matcher_options) return boolean,
   member procedure desc_compound_data(
     self in out nocopy ut_cursor_details,
     a_compound_data anytype,
     a_parent_name in varchar2,
     a_level in integer,
     a_access_path in varchar2
   ),
   member function  contains_collection return boolean,
   member function  get_missing_join_by_columns( a_expected_columns ut_varchar2_list ) return ut_varchar2_list,
   member procedure filter_columns(self in out nocopy ut_cursor_details, a_match_options ut_matcher_options),
   member function  get_xml_children(a_parent_name varchar2 := null) return xmltype,
   member function get_root return varchar2,
   member procedure strip_root_from_anydata(self in out nocopy ut_cursor_details)
)
/
