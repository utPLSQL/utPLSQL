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
    self in out nocopy ut_sonar_test_reporter
  ) return self as result is
  begin
    self.init($$plsql_unit);
    return;
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_sonar_test_reporter, a_run in ut_run) is

    function map_package_to_file(a_suite ut_suite, a_file_mappings ut_file_mappings) return varchar2 is
    l_file_name varchar2(4000);
    begin
      if a_file_mappings is not null then
        for i in 1 .. a_file_mappings.count loop
          if upper(a_file_mappings(i).object_name) = upper(a_suite.object_name)
            and upper(a_file_mappings(i).object_owner) = upper(a_suite.object_owner) 
            and a_file_mappings(i).object_type = 'PACKAGE BODY' then
            l_file_name := a_file_mappings(i).file_name;
            exit;
          end if;
        end loop;
      end if;
      return coalesce(l_file_name, a_suite.path);
    end;

    procedure print_test_results(a_test ut_test) is
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

    procedure print_suite_results(a_suite ut_logical_suite, a_file_mappings ut_file_mappings) is
    begin
      for i in 1 .. a_suite.items.count loop
        if a_suite.items(i) is of(ut_logical_suite) then
          print_suite_results(treat(a_suite.items(i) as ut_logical_suite), a_file_mappings);
        end if;
      end loop;
      if a_suite is of(ut_suite) then
        self.print_text('<file path="'||map_package_to_file(treat(a_suite as ut_suite), a_file_mappings)||'">');

        for i in 1 .. a_suite.items.count loop
          if a_suite.items(i) is of(ut_test) then
            print_test_results(treat(a_suite.items(i) as ut_test));
          end if;
        end loop;
        self.print_text('</file>');
      end if;
    end;

  begin
    self.print_text('<testExecutions version="1">');
    for i in 1 .. a_run.items.count loop
      print_suite_results(treat(a_run.items(i) as ut_logical_suite), a_run.test_file_mappings);
    end loop;

    self.print_text('</testExecutions>');
  end;

end;
/
