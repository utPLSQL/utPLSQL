create or replace type body ut_sonar_test_reporter is
  /*
  utPLSQL - Version X.X.X.X
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

  constructor function ut_sonar_test_reporter(
    self in out nocopy ut_sonar_test_reporter,
    a_object_owner varchar2 := null,
    a_file_paths ut_varchar2_list,
    a_regex_pattern varchar2,
    a_object_owner_subexpression positive,
    a_object_name_subexpression positive,
    a_object_type_subexpression positive,
    a_file_to_object_type_mapping ut_key_value_pairs
  ) return self as result is
  begin
    self.file_mappings := ut_coverage.build_file_mappings(
      a_object_owner, a_file_paths, a_file_to_object_type_mapping, a_regex_pattern,
      a_object_owner_subexpression, a_object_name_subexpression, a_object_type_subexpression
    );
    self.init($$plsql_unit);
    return;
  end;

  constructor function ut_sonar_test_reporter(
    self in out nocopy ut_sonar_test_reporter,
    a_object_owner varchar2 := null,
    a_file_paths ut_varchar2_list
  ) return self as result is
  begin
    self.file_mappings := coalesce(ut_coverage.build_file_mappings( a_object_owner, a_file_paths ), ut_coverage_file_mappings());
    self.init($$plsql_unit);
    return;
  end;

  constructor function ut_sonar_test_reporter(
    self in out nocopy ut_sonar_test_reporter,
    a_file_mappings    ut_coverage_file_mappings
  ) return self as result is
  begin
    self.init($$plsql_unit);
    self.file_mappings := coalesce(a_file_mappings,ut_coverage_file_mappings());
    return;
  end;

  overriding member procedure before_calling_run(self in out nocopy ut_sonar_test_reporter, a_run in ut_run) is
  begin
    self.print_text('<testExecutions version="1">');
  end;

  overriding member procedure before_calling_suite(self in out nocopy ut_sonar_test_reporter, a_suite ut_logical_suite) is
    l_file_name varchar2(4000);
  begin
    for i in 1 .. self.file_mappings.count loop
      if upper(self.file_mappings(i).object_name) = upper(a_suite.object_name)
        and upper(self.file_mappings(i).object_owner) = upper(a_suite.object_owner) then
        l_file_name := self.file_mappings(i).file_name;
        exit;
      end if;
    end loop;
    l_file_name := coalesce(l_file_name, a_suite.path);
    self.print_text('<file path="'||l_file_name||'">');
  end;

  overriding member procedure after_calling_test(self in out nocopy ut_sonar_test_reporter, a_test ut_test) is
    l_message varchar2(32757);
    l_lines ut_varchar2_list;
  begin
    self.print_text('<testCase name="'||a_test.name||'" duration="'||round(a_test.execution_time()*1000,0)||'" >');
    if a_test.result = ut_utils.tr_disabled then
      self.print_text('<skipped message="skipped"/>');
    elsif a_test.result = ut_utils.tr_error then
      self.print_text('<error message="encountered errors">');
      self.print_text('<![CDATA[');
      self.print_clob(ut_utils.table_to_clob(a_test.get_error_stack_traces()));
      self.print_text(']]>');
      self.print_text('</error>');
    elsif a_test.result > ut_utils.tr_success then
      self.print_text('<failure message="some expectations have failed">');
      self.print_text('<![CDATA[');
      for i in 1 .. a_test.results.count loop
        l_lines := a_test.results(i).get_result_lines();
        for i in 1 .. l_lines.count loop
          self.print_text(l_lines(i));
        end loop;
      end loop;
      self.print_text(']]>');
      self.print_text('</failure>');
    end if;
    self.print_text('</testCase>');
  end;

  overriding member procedure after_calling_suite(self in out nocopy ut_sonar_test_reporter, a_suite ut_logical_suite) is
  begin
    self.print_text('</file>');
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_sonar_test_reporter, a_run in ut_run) is
  begin
    self.print_text('</testExecutions>');
  end;

end;
/
