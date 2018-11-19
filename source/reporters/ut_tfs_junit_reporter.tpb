create or replace type body ut_tfs_junit_reporter is
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

  constructor function ut_tfs_junit_reporter(self in out nocopy ut_tfs_junit_reporter) return self as result is
  begin
    self.init($$plsql_unit);
    return;
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_tfs_junit_reporter, a_run in ut_run) is
  begin  
     junit_version_one(a_run);
  end;

 member procedure junit_version_one(self in out nocopy ut_tfs_junit_reporter,a_run in ut_run) is
    l_suite_id    integer := 0;
    l_tests_count integer := a_run.results_count.disabled_count + a_run.results_count.success_count +
                             a_run.results_count.failure_count + a_run.results_count.errored_count;
     
    function get_common_suite_attributes(a_item ut_suite_item) return varchar2 is
    begin
     return ' errors="' ||a_item.results_count.errored_count || '"' || 
            ' failures="' || a_item.results_count.failure_count || 
            '" name="' || dbms_xmlgen.convert(nvl(a_item.description, a_item.name)) || '"' || 
            ' time="' || ut_utils.to_xml_number_format(a_item.execution_time()) || '" '||
            ' timestamp="' || to_char(sysdate,'RRRR-MM-DD"T"HH24:MI:SS') || '" '||
            ' hostname="' || sys_context('USERENV','HOST') || '" ';
    end;
 
     function get_common_testcase_attributes(a_item ut_suite_item) return varchar2 is
    begin
     return ' name="' || dbms_xmlgen.convert(nvl(a_item.description, a_item.name)) || '"' || 
            ' time="' || ut_utils.to_xml_number_format(a_item.execution_time()) || '"';
    end;
                             
    function get_path(a_path_with_name varchar2, a_name varchar2) return varchar2 is
    begin
      return regexp_substr(a_path_with_name, '(.*)\.' ||a_name||'$',subexpression=>1);
    end;

    procedure print_test_results(a_test ut_test) is
      l_results ut_varchar2_rows := ut_varchar2_rows();
      l_lines   ut_varchar2_list;
    begin
      self.print_text('<testcase classname="' || dbms_xmlgen.convert(get_path(a_test.path, a_test.name)) || '" ' || 
                      get_common_testcase_attributes(a_test) || '>');
      /*
      According to specs :
      - A failure is a test which the code has explicitly failed by using the mechanisms for that purpose. 
        e.g., via an assertEquals
      - An errored test is one that had an unanticipated problem. 
        e.g., an unchecked throwable; or a problem with the implementation of the test.
      */
      
      if a_test.result = ut_utils.gc_error then
        ut_utils.append_to_list( l_results, '<error type="error" message="Error while executing '||a_test.name||'">');
        ut_utils.append_to_list( l_results, '<![CDATA[');
        ut_utils.append_to_list( l_results, ut_utils.table_to_clob(a_test.get_error_stack_traces()));
        ut_utils.append_to_list( l_results, ']]>');
        ut_utils.append_to_list( l_results, '</error>');
     -- Do not count error as failure
      elsif a_test.result = ut_utils.gc_failure then
        ut_utils.append_to_list( l_results, '<failure type="failure" message="Test '||a_test.name||' failed">');
        for i in 1 .. a_test.failed_expectations.count loop
          l_lines := a_test.failed_expectations(i).get_result_lines();
          for j in 1 .. l_lines.count loop
            ut_utils.append_to_list( l_results, dbms_xmlgen.convert(l_lines(j)));
          end loop;
          ut_utils.append_to_list( l_results, dbms_xmlgen.convert(a_test.failed_expectations(i).caller_info));
        end loop;
        ut_utils.append_to_list( l_results, '</failure>');
      end if;

      ut_utils.append_to_list( l_results, '</testcase>');

      self.print_text_lines(l_results);
    end;

    procedure print_suite_results(a_suite ut_logical_suite, a_suite_id in out nocopy integer) is
      l_tests_count integer := a_suite.results_count.disabled_count + a_suite.results_count.success_count +
                               a_suite.results_count.failure_count + a_suite.results_count.errored_count;
      l_results     ut_varchar2_rows := ut_varchar2_rows();
      l_suite       ut_suite;
      l_outputs     clob;
      l_errors      ut_varchar2_list;
    begin
      
      for i in 1 .. a_suite.items.count loop
        if a_suite.items(i) is of(ut_logical_suite) then
          print_suite_results(treat(a_suite.items(i) as ut_logical_suite), a_suite_id);
        end if;
      end loop;     
     
    if a_suite is of(ut_suite) then
       a_suite_id := a_suite_id + 1;
       self.print_text('<testsuite tests="' || l_tests_count || '"' || ' id="' || a_suite_id || '"' || ' package="' ||
                      dbms_xmlgen.convert(a_suite.path) || '" ' || get_common_suite_attributes(a_suite) || '>');
       self.print_text('<properties/>');
        for i in 1 .. a_suite.items.count loop
          if a_suite.items(i) is of(ut_test) then
            print_test_results(treat(a_suite.items(i) as ut_test));
          end if;
        end loop;
        l_suite := treat(a_suite as ut_suite);
        l_outputs := l_suite.get_serveroutputs();
        if l_outputs is not null and l_outputs != empty_clob() then
          ut_utils.append_to_list( l_results, '<system-out>');
          ut_utils.append_to_list( l_results, '<![CDATA[');
          ut_utils.append_to_list( l_results, l_outputs);
          ut_utils.append_to_list( l_results, ']]>');
          ut_utils.append_to_list( l_results, '</system-out>');
        else 
          ut_utils.append_to_list( l_results, '<system-out/>');
        end if;

        l_errors := l_suite.get_error_stack_traces();
        if l_errors is not empty then
          ut_utils.append_to_list( l_results, '<system-err>');
          ut_utils.append_to_list( l_results, '<![CDATA[');
          ut_utils.append_to_list( l_results, ut_utils.table_to_clob(l_errors));
          ut_utils.append_to_list( l_results, ']]>');
          ut_utils.append_to_list( l_results, '</system-err>');
        else
          ut_utils.append_to_list( l_results, '<system-err/>');
        end if;
        ut_utils.append_to_list( l_results, '</testsuite>');

        self.print_text_lines(l_results);
      end if;
    end; 
      
  begin
    l_suite_id := 0;
    self.print_text(ut_utils.get_xml_header(a_run.client_character_set));
    self.print_text('<testsuites>');
    for i in 1 .. a_run.items.count loop
      print_suite_results(treat(a_run.items(i) as ut_logical_suite), l_suite_id);
    end loop;
    self.print_text('</testsuites>');
  end;

  overriding member function get_description return varchar2 as
  begin
    return 'Provides outcomes in a format conforming with JUnit version for TFS / VSTS.
    As defined by specs :https://docs.microsoft.com/en-us/vsts/build-release/tasks/test/publish-test-results?view=vsts
    Version is based on windy road junit https://github.com/windyroad/JUnit-Schema/blob/master/JUnit.xsd.';
  end;

end;
/
