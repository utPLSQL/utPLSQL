create or replace type ut_data_value authid current_user as object (
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2017 utPLSQL Project

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
  data_type         varchar2(250 char),
  self_type         varchar2(250 char),
  not instantiable member function is_null return boolean,
  not instantiable member function to_string return varchar2,
  member function is_multi_line return boolean,
  final member function format_multi_line( a_string varchar2) return varchar2,
  final member function to_string_report(a_add_new_line_for_multi_line boolean := false, a_with_type_name boolean := true) return varchar2,
  order member function compare( a_other ut_data_value ) return integer,
  member function is_diffable return boolean,
  member function diff( a_other ut_data_value ) return varchar2,
  not instantiable member function compare_implementation( a_other ut_data_value ) return integer
) not final not instantiable
/
