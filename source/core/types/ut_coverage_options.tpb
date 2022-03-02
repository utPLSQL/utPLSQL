create or replace type body ut_coverage_options as
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

  constructor function ut_coverage_options(
    self       in out nocopy ut_coverage_options,
    coverage_run_id          raw,
    schema_names             ut_varchar2_rows := null,
    exclude_objects          ut_varchar2_rows := null,
    include_objects          ut_varchar2_rows := null,
    file_mappings            ut_file_mappings := null,
    include_schema_expr varchar2 := null,
    include_object_expr varchar2 := null,
    exclude_schema_expr varchar2 := null,
    exclude_object_expr varchar2 := null    
    ) return self as result is
    function to_ut_object_list(a_names ut_varchar2_rows, a_schema_names ut_varchar2_rows) return ut_object_names is
      l_result      ut_object_names;
      l_object_name ut_object_name;
    begin
      if a_names is not empty then
        l_result := ut_object_names();
        for i in 1 .. a_names.count loop
          l_object_name := ut_object_name(a_names(i));
          if l_object_name.owner is null then
            for i in 1 .. cardinality(a_schema_names) loop
              l_result.extend;
              l_result(l_result.last) := ut_object_name(a_schema_names(i)||'.'||l_object_name.name);
            end loop;
          else
            l_result.extend;
            l_result(l_result.last) := l_object_name;
          end if;
        end loop;
      end if;
      return l_result;
    end;
  begin
    self.coverage_run_id := coverage_run_id;
    self.file_mappings   := file_mappings;
    self.schema_names    := schema_names;
    self.exclude_objects := ut_object_names();

    if exclude_objects is not empty then
      self.exclude_objects := to_ut_object_list(exclude_objects, self.schema_names);
    end if;

    self.include_objects := to_ut_object_list(include_objects, self.schema_names);

    self.include_schema_expr := include_schema_expr;
    self.include_object_expr := include_object_expr;
    self.exclude_schema_expr := exclude_schema_expr;
    self.exclude_object_expr := exclude_object_expr;


    return;
  end;
end;
/
