create or replace type body ut_xunit_reporter is
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

  constructor function ut_xunit_reporter(self in out nocopy ut_xunit_reporter) return self as result is
  begin
    self.init($$plsql_unit);
    return;
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_xunit_reporter, a_run in ut_run) is
    l_suite_id    integer := 0;
    l_tests_count integer := a_run.results_count.disabled_count + a_run.results_count.success_count +
                             a_run.results_count.failure_count + a_run.results_count.errored_count;

    function get_path(a_path_with_name varchar2, a_name varchar2) return varchar2 is
    begin
      return substr(a_path_with_name, 1, instr(a_path_with_name, '.' || a_name) - 1);
    end;

    procedure print_test_elements(a_test ut_test) is
      l_lines ut_varchar2_list;
      l_output clob;
    begin
      self.print_text('<testcase classname="' || dbms_xmlgen.convert(get_path(a_test.path, a_test.name)) || '" ' || ' assertions="' ||
                      nvl(a_test.expectations_count,0) || '"' || self.get_common_item_attributes(a_test) || case when
                      a_test.result != ut_utils.tr_success then
                      ' status="' || ut_utils.test_result_to_char(a_test.result) || '"' end || '>');
      if a_test.result = ut_utils.tr_disabled then
        self.print_text('<skipped/>');
      end if;
      if a_test.result = ut_utils.tr_error then
        self.print_text('<error>');
        self.print_text('<![CDATA[');
        self.print_clob(ut_utils.table_to_clob(a_test.get_error_stack_traces()));
        self.print_text(']]>');
        self.print_text('</error>');
      elsif a_test.result > ut_utils.tr_success then
        self.print_text('<failure>');
        self.print_text('<![CDATA[');
        for i in 1 .. a_test.results.count loop
          l_lines := a_test.results(i).get_result_lines();
          for j in 1 .. l_lines.count loop
            self.print_text(l_lines(j));
          end loop;
          self.print_text(a_test.results(i).caller_info);
        end loop;
        self.print_text(']]>');
        self.print_text('</failure>');
      end if;
      -- TODO - decide if we need/want to use the <system-err/> tag too
      l_output := a_test.get_serveroutputs();
      if l_output is not null then
        self.print_text('<system-out>');
        self.print_text('<![CDATA[');
        self.print_clob(l_output);
        self.print_text(']]>');
        self.print_text('</system-out>');
      end if;
      self.print_text('</testcase>');
    end;

    procedure print_suite_elements(a_suite ut_logical_suite, a_suite_id in out nocopy integer) is
      l_tests_count integer := a_suite.results_count.disabled_count + a_suite.results_count.success_count +
                               a_suite.results_count.failure_count + a_suite.results_count.errored_count;
      l_suite       ut_suite;
    begin
      a_suite_id := a_suite_id + 1;
      self.print_text('<testsuite tests="' || l_tests_count || '"' || ' id="' || a_suite_id || '"' || ' package="' ||
                      dbms_xmlgen.convert(a_suite.path) || '" ' || self.get_common_item_attributes(a_suite) || '>');
      if a_suite is of(ut_suite) then
        l_suite := treat(a_suite as ut_suite);

        if l_suite.before_all.serveroutput is not null or l_suite.after_all.serveroutput is not null then
          self.print_text('<system-out>');
          self.print_text('<![CDATA[');
          self.print_clob(l_suite.get_serveroutputs());
          self.print_text(']]>');
          self.print_text('</system-out>');
        end if;

        if l_suite.before_all.error_stack is not null or l_suite.after_all.error_stack is not null then
          self.print_text('<system-err>');
          self.print_text('<![CDATA[');
          self.print_text(trim(l_suite.before_all.error_stack) || trim(chr(10) || chr(10) || l_suite.after_all.error_stack));
          self.print_text(']]>');
          self.print_text('</system-err>');
        end if;
      end if;

      for i in 1 .. a_suite.items.count loop
        if a_suite.items(i) is of(ut_test) then
          print_test_elements(treat(a_suite.items(i) as ut_test));
        elsif a_suite.items(i) is of(ut_logical_suite) then
          print_suite_elements(treat(a_suite.items(i) as ut_logical_suite), a_suite_id);
        end if;
      end loop;
      self.print_text('</testsuite>');
    end;
  begin
    l_suite_id := 0;
    self.print_text('<testsuites tests="' || l_tests_count || '"' || self.get_common_item_attributes(a_run) || '>');
    for i in 1 .. a_run.items.count loop
      print_suite_elements(treat(a_run.items(i) as ut_logical_suite), l_suite_id);
    end loop;
    self.print_text('</testsuites>');
    (self as ut_reporter_base).after_calling_run(a_run);
  end;

  member function get_common_item_attributes(a_item ut_suite_item) return varchar2 is
  begin
    return ' skipped="' || a_item.results_count.disabled_count || '" error="' || a_item.results_count.errored_count || '"' || ' failure="' || a_item.results_count.failure_count || '" name="' || dbms_xmlgen.convert(nvl(a_item.description, a_item.name)) || '"' || ' time="' || a_item.execution_time() || '" ';
  end;

end;
/
