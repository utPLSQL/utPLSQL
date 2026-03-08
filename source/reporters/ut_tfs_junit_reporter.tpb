create or replace type body ut_tfs_junit_reporter is
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

  constructor function ut_tfs_junit_reporter(self in out nocopy ut_tfs_junit_reporter) return self as result is
  begin
    self.init($$plsql_unit,ut_output_bulk_buffer());
    return;
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_tfs_junit_reporter, a_run in ut_run) is
  begin  
     junit_version_one(a_run);
  end;

 member procedure junit_version_one(self in out nocopy ut_tfs_junit_reporter,a_run in ut_run) is
    l_suite_id    integer := 0;

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

    function add_test_results(a_test ut_test) return ut_varchar2_rows is
      l_results ut_varchar2_rows := ut_varchar2_rows();
    begin
      ut_utils.append_to_list( l_results,'<testcase classname="' || dbms_xmlgen.convert(get_path(a_test.path, a_test.name)) || '" ' || 
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
        ut_utils.append_to_list( l_results, ut_utils.to_cdata( ut_utils.convert_collection( a_test.get_error_stack_traces() ) ) );
        ut_utils.append_to_list( l_results, '</error>');
     -- Do not count error as failure
      elsif a_test.result = ut_utils.gc_disabled then
        if a_test.disabled_reason is not null then
          ut_utils.append_to_list( l_results, '<skipped type="skipped" message="'||a_test.disabled_reason||'"/>');
        else
          ut_utils.append_to_list( l_results, '<skipped/>' );
        end if;      
      elsif a_test.result = ut_utils.gc_failure then
        ut_utils.append_to_list( l_results, '<failure type="failure" message="Test '||a_test.name||' failed">');
        ut_utils.append_to_list( l_results, ut_utils.to_cdata( a_test.get_failed_expectation_lines() ) );
        ut_utils.append_to_list( l_results, '</failure>');
      end if;

      ut_utils.append_to_list( l_results, '</testcase>');

      return l_results;
    end;

    procedure print_suite_results(a_suite ut_logical_suite, a_suite_id in out nocopy integer, a_nested_tests in out nocopy ut_varchar2_rows) is
      l_tests_count integer := a_suite.results_count.disabled_count + a_suite.results_count.success_count +
                               a_suite.results_count.failure_count + a_suite.results_count.errored_count;
      l_results     ut_varchar2_rows := ut_varchar2_rows();
      l_suite       ut_suite;
      l_outputs     clob;
      l_errors      ut_varchar2_list;
      l_tests       ut_varchar2_list;
    begin      
      for i in 1 .. a_suite.items.count loop
        if a_suite.items(i) is of(ut_suite_context) then
          print_suite_results(treat(a_suite.items(i) as ut_suite_context), a_suite_id, a_nested_tests);   
        elsif a_suite.items(i) is of(ut_suite) then
          print_suite_results(treat(a_suite.items(i) as ut_suite), a_suite_id, a_nested_tests);   
        elsif a_suite.items(i) is of(ut_logical_suite) then
          print_suite_results(treat(a_suite.items(i) as ut_logical_suite), a_suite_id, a_nested_tests);            
        end if;
      end loop;     
      --Due to fact tha TFS and junit5 accepts only flat structure we have to report in suite level only.
      if a_suite is of(ut_suite_context) then
         for i in 1 .. a_suite.items.count loop
           if a_suite.items(i) is of(ut_test) then
             ut_utils.append_to_list( a_nested_tests,(add_test_results(treat(a_suite.items(i) as ut_test))));
           end if;
         end loop;
      elsif a_suite is of(ut_suite) then
         for i in 1 .. a_suite.items.count loop
           if a_suite.items(i) is of(ut_test) then
             ut_utils.append_to_list( a_nested_tests,(add_test_results(treat(a_suite.items(i) as ut_test))));
           end if;
         end loop; 
           --TFS doesnt report on empty test suites, however all we want to make sure is that we dont pring parents suites
           -- showing test count but not tests.
           if (a_nested_tests.count > 0 and l_tests_count > 0) or (a_nested_tests.count = 0 and l_tests_count = 0)  then
           a_suite_id := a_suite_id + 1;
           ut_utils.append_to_list( l_results,'<testsuite tests="' || l_tests_count || '"' || ' id="' || a_suite_id || '"' || ' package="' ||
                          dbms_xmlgen.convert(a_suite.path) || '" ' || get_common_suite_attributes(a_suite) || '>');
           ut_utils.append_to_list( l_results,'<properties/>');
           ut_utils.append_to_list(l_results,a_nested_tests);
           l_suite := treat(a_suite as ut_suite);
           l_outputs := l_suite.get_serveroutputs();
           if l_outputs is not null and l_outputs != empty_clob() then
             ut_utils.append_to_list( l_results, '<system-out>');
             ut_utils.append_to_list( l_results, ut_utils.to_cdata( l_suite.get_serveroutputs() ) );
             ut_utils.append_to_list( l_results, '</system-out>');
           else
             ut_utils.append_to_list( l_results, '<system-out/>');
           end if;
  
           l_errors := l_suite.get_error_stack_traces();
           if l_errors is not empty then
             ut_utils.append_to_list( l_results, '<system-err>');
             ut_utils.append_to_list( l_results, ut_utils.to_cdata( ut_utils.convert_collection( l_errors ) ) );
             ut_utils.append_to_list( l_results, '</system-err>');
           else
             ut_utils.append_to_list( l_results, '<system-err/>');
           end if;
           ut_utils.append_to_list( l_results, '</testsuite>');
  
           self.print_text_lines(l_results);
           --We have resolved a context and we now reset value.
           a_nested_tests := ut_varchar2_rows();
        end if;
      end if;
    end;
    
    procedure get_suite_results(a_suite ut_logical_suite, a_suite_id in out nocopy integer) is
      l_nested_tests ut_varchar2_rows:= ut_varchar2_rows();
    begin
      print_suite_results(a_suite, l_suite_id,l_nested_tests);
    end;
      
  begin
    l_suite_id := 0;
    self.print_text(ut_utils.get_xml_header(a_run.client_character_set));
    self.print_text('<testsuites>');
    for i in 1 .. a_run.items.count loop
      get_suite_results(treat(a_run.items(i) as ut_logical_suite), l_suite_id);
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
