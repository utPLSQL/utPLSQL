create or replace type body ut_data_value_object as
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

  constructor function ut_data_value_object(self in out nocopy ut_data_value_object, a_value anydata) return self as result is
  begin
    self.self_type  := $$plsql_unit;
    self.init(a_value, 'object', '/*/*');
    return;
  end;

  overriding member function get_object_info return varchar2 is
  begin
    return self.data_type;
  end;

end;
/
