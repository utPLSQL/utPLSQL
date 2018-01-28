create or replace type ut_data_value_anydata under ut_data_value(
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

  data_value anydata,

  data_value_is_null integer,
  overriding member function to_string return varchar2,
  overriding member function compare_implementation(a_other ut_data_value) return integer,
  member function compare_implementation(a_other ut_data_value, a_exclude_xpath varchar2, a_include_xpath varchar2) return integer,
  final member procedure init(self in out nocopy ut_data_value_anydata, a_value anydata, a_data_object_type varchar2),
  overriding member function is_null return boolean,
  static function get_instance(a_data_value anydata) return ut_data_value_anydata
) not final not instantiable
/
