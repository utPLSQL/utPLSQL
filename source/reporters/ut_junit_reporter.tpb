create or replace type body ut_junit_reporter is
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
    
  constructor function ut_junit_reporter(self in out nocopy ut_junit_reporter) return self as result is
  begin
    self.init($$plsql_unit);
    return;
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_junit_reporter, a_run in ut_run) is
    c_cddata_tag_start constant varchar2(30) := '<![CDATA[';
    c_cddata_tag_end   constant varchar2(10) := ']]>';
    l_suite_id    integer := 0;
    l_tests_count integer := a_run.results_count.disabled_count + a_run.results_count.success_count +
                             a_run.results_count.failure_count + a_run.results_count.errored_count;

    function get_path(a_path_with_name varchar2, a_name varchar2) return varchar2 is
    begin
      return regexp_substr(a_path_with_name, '(.*)\.' ||a_name||'$',subexpression=>1);
    end;

    procedure print_test_elements(a_test ut_test) is
      l_lines ut_varchar2_list;
      l_output clob;
    begin
      self.print_text('<testcase classname="' || dbms_xmlgen.convert(get_path(a_test.path, a_test.name)) || '"' || ' assertions="' ||
                      nvl(a_test.all_expectations.count,0) || self.get_common_item_attributes(a_test) || case when
                      a_test.result != ut_utils.gc_success then
                      ' status="' || ut_utils.test_result_to_char(a_test.result) || '"' end || '>');
      if a_test.result = ut_utils.gc_disabled then
        self.print_text('<skipped/>');
      end if;
      if a_test.result = ut_utils.gc_error then
        self.print_text('<error>');
        self.print_text(c_cddata_tag_start);
        self.print_clob(ut_utils.table_to_clob(a_test.get_error_stack_traces()));
        self.print_text(c_cddata_tag_end);
        self.print_text('</error>');
      elsif a_test.result > ut_utils.gc_success then
        self.print_text('<failure>');
        for i in 1 .. a_test.failed_expectations.count loop
          
          l_lines := a_test.failed_expectations(i).get_result_lines();
          
          for j in 1 .. l_lines.count loop
            self.print_text(dbms_xmlgen.convert(l_lines(j)));
          end loop;
          self.print_text(dbms_xmlgen.convert(a_test.failed_expectations(i).caller_info));
        end loop;
        self.print_text('</failure>');
      end if;
      -- TODO - decide if we need/want to use the <system-err/> tag too
      l_output := a_test.get_serveroutputs();
      if l_output is not null then
        self.print_text('<system-out>');
        self.print_text(c_cddata_tag_start);
        self.print_clob(l_output);
        self.print_text(c_cddata_tag_end);
        self.print_text('</system-out>');
      else
        self.print_text('<system-out/>');
      end if;
      self.print_text('<system-err/>');
      self.print_text('</testcase>');
    end;

    procedure print_suite_elements(a_suite ut_logical_suite, a_suite_id in out nocopy integer) is
      l_tests_count integer := a_suite.results_count.disabled_count + a_suite.results_count.success_count +
                               a_suite.results_count.failure_count + a_suite.results_count.errored_count;
      l_suite       ut_suite;
      l_tests       ut_suite_items := ut_suite_items();
      l_data        clob;
      l_errors      ut_varchar2_list;
    begin
      a_suite_id := a_suite_id + 1;
      self.print_text('<testsuite tests="' || l_tests_count || '"' || ' id="' || a_suite_id || '"' || ' package="' ||
                      dbms_xmlgen.convert(a_suite.path) || '" ' || self.get_common_suite_attributes(a_suite) || '>');   
      
       -- Becasue testsuites have to appear before test we capture test and leave it for later.
       for i in 1 .. a_suite.items.count loop
        if a_suite.items(i) is of(ut_test) then
          l_tests.extend;
          l_tests(l_tests.last) :=  treat(a_suite.items(i) as ut_test);
        elsif a_suite.items(i) is of(ut_logical_suite) then
          print_suite_elements(treat(a_suite.items(i) as ut_logical_suite), a_suite_id);
        end if;
      end loop;
      
      -- Now when all testsuite are printed do the testcases.
      for i in 1 .. l_tests.count loop
       print_test_elements(treat(l_tests(i) as ut_test));
      end loop;
      
      if a_suite is of(ut_suite) then
        l_suite := treat(a_suite as ut_suite);

        l_data := l_suite.get_serveroutputs();
        if l_data is not null and l_data != empty_clob() then
          self.print_text('<system-out>');
          self.print_text(c_cddata_tag_start);
          self.print_clob(l_data);
          self.print_text(c_cddata_tag_end);
          self.print_text('</system-out>');
        else
          self.print_text('<system-out/>');
        end if;

        l_errors := l_suite.get_error_stack_traces();
        if l_errors is not empty then
          self.print_text('<system-err>');
          self.print_text(c_cddata_tag_start);
          self.print_clob(ut_utils.table_to_clob(l_errors));
          self.print_text(c_cddata_tag_end);
          self.print_text('</system-err>');
        else
          self.print_text('<system-err/>');
        end if;
      end if;
      self.print_text('</testsuite>');
    end;
  begin
    l_suite_id := 0;
    self.print_text(ut_utils.get_xml_header(a_run.client_character_set));
    self.print_text('<testsuites tests="' || l_tests_count || '"' || self.get_common_suite_attributes(a_run) || '>');
    for i in 1 .. a_run.items.count loop
      print_suite_elements(treat(a_run.items(i) as ut_logical_suite), l_suite_id);
    end loop;
    self.print_text('</testsuites>');
  end;

  member function get_common_item_attributes(a_item ut_suite_item) return varchar2 is
  begin
    return '" name="' || dbms_xmlgen.convert(nvl(a_item.description, a_item.name))
           || '" time="' || ut_utils.to_xml_number_format(a_item.execution_time()) || '" ';
  end;

  member function get_common_suite_attributes(a_item ut_suite_item) return varchar2 is
  begin
    return ' disabled="' || a_item.results_count.disabled_count
           || '" errors="' || a_item.results_count.errored_count
           || '" failures="' || a_item.results_count.failure_count
           ||  get_common_item_attributes(a_item);
  end;

  overriding member function get_description return varchar2 as
  begin
    return 'Provides outcomes in a format conforming with JUnit 4 and above as defined in: https://gist.github.com/kuzuha/232902acab1344d6b578';
  end;

end;
/
