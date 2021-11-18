create or replace type body ut_suite_context as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project

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

  constructor function ut_suite_context (
    self in out nocopy ut_suite_context, a_object_owner varchar2, a_object_name varchar2, a_context_name varchar2 := null, a_line_no integer
  ) return self as result is
  begin
    self.self_type := $$plsql_unit;
    self.init(a_object_owner, a_object_name, a_context_name, a_line_no);
    self.items := ut_suite_items();
    before_all_list := ut_executables();
    after_all_list  := ut_executables();
    return;
  end;

end;
/
