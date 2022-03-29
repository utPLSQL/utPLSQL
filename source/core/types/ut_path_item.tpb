create or replace type body ut_path_item as
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
  constructor function ut_path_item(self in out nocopy ut_path_item, schema_name varchar2, object_name varchar2,procedure_name varchar2) return self as result is
  begin
    self.schema_name := schema_name;
    self.object_name := object_name;
    self.procedure_name :=  procedure_name;
    return;
  end;

  constructor function ut_path_item(self in out nocopy ut_path_item, schema_name varchar2,suite_path varchar2) return self as result is
  begin
    self.schema_name := schema_name;
    self.suite_path := suite_path;
    return;
  end;

  constructor function ut_path_item(self in out nocopy ut_path_item, schema_name varchar2, object_name varchar2,procedure_name varchar2,suite_path varchar2) return self as result is
  begin
    self.schema_name := schema_name;
    self.object_name := object_name;
    self.procedure_name :=  procedure_name;
    self.suite_path :=  suite_path;
    return;
  end;  
end;
/