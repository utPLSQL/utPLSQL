create or replace type body ut_sonar_test_reporter is
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
      l_results             ut_varchar2_rows := ut_varchar2_rows();
    begin
      ut_utils.append_to_list( l_results, '<testCase name="'||dbms_xmlgen.convert(a_test.name)||'" duration="'||round(a_test.execution_time()*1000,0)||'" >');
      if a_test.result = ut_utils.gc_disabled then
        ut_utils.append_to_list( l_results, '<skipped message="skipped"/>');
      elsif a_test.result = ut_utils.gc_error then
        ut_utils.append_to_list( l_results, '<error message="encountered errors">');
        ut_utils.append_to_list( l_results, ut_utils.to_cdata( ut_utils.convert_collection( a_test.get_error_stack_traces() ) ) );
        ut_utils.append_to_list( l_results, '</error>');
      elsif a_test.result > ut_utils.gc_success then
        ut_utils.append_to_list( l_results, '<failure message="some expectations have failed">');
        ut_utils.append_to_list( l_results, ut_utils.to_cdata( a_test.get_failed_expectation_lines() ) );
        ut_utils.append_to_list( l_results, '</failure>');
      end if;
      ut_utils.append_to_list( l_results, '</testCase>');

      self.print_text_lines(l_results);
    end;

    procedure print_suite_results(a_suite ut_logical_suite, a_file_mappings ut_file_mappings) is
    begin

      for i in 1 .. a_suite.items.count loop
        if a_suite.items(i) is of(ut_logical_suite) and a_suite.items(i) is not of(ut_suite_context) then
          print_suite_results(treat(a_suite.items(i) as ut_logical_suite), a_file_mappings);
        end if;
      end loop;

      if a_suite is of(ut_suite) and a_suite is not of(ut_suite_context) then
        self.print_text('<file path="'||dbms_xmlgen.convert(map_package_to_file(treat(a_suite as ut_suite), a_file_mappings))||'">');
      end if;

      for i in 1 .. a_suite.items.count loop
        if a_suite.items(i) is of(ut_suite_context) then
          print_suite_results(treat(a_suite.items(i) as ut_suite_context), a_file_mappings);
        end if;
      end loop;

      if a_suite is of(ut_suite) then
        for i in 1 .. a_suite.items.count loop
          if a_suite.items(i) is of(ut_test) then
            print_test_results(treat(a_suite.items(i) as ut_test));
          end if;
        end loop;
      end if;

      if a_suite is of(ut_suite) and a_suite is not of(ut_suite_context) then
        self.print_text('</file>');
      end if;
    end;

  begin
    self.print_text(ut_utils.get_xml_header(a_run.client_character_set));
    self.print_text('<testExecutions version="1">');
    for i in 1 .. a_run.items.count loop
      print_suite_results(treat(a_run.items(i) as ut_logical_suite), a_run.test_file_mappings);
    end loop;

    self.print_text('</testExecutions>');
  end;

  overriding member function get_description return varchar2 as
  begin
    return 'Generates a JSON report providing detailed information on test execution.' || chr(10) ||
           'Designed for [SonarQube](https://about.sonarqube.com/) to report test execution.' || chr(10) ||
           'JSON format returned conforms with the Sonar specification: https://docs.sonarqube.org/display/SONAR/Generic+Test+Data';
  end;

end;
/
