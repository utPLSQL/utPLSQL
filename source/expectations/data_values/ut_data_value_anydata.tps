create or replace type ut_data_value_anydata under ut_compound_data_value(
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

  final member procedure init(self in out nocopy ut_data_value_anydata, a_value anydata, a_data_object_type varchar2, a_extract_path varchar2),
  static function get_instance(a_data_value anydata) return ut_data_value_anydata
) not final not instantiable
/
