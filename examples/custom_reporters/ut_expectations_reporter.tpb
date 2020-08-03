create or replace type body ut_expectations_reporter is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2020 utPLSQL Project

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

  constructor function ut_expectations_reporter(a_report_all_expectations varchar2 := 'Y')return self as result is
  begin
    self.init($$plsql_unit);
    self.lvl                       := 0;
    self.report_all_expectations   := substr(a_report_all_expectations,1,1);
    self.failed_test_running_count := 0;
    return;
  end;

  /* The reporter procedure after_calling_test from ut_documentation_reporter is overriden here so that:
     - the test name is printed
     - the test staus is printed
     - test duration is printed
     - all expectation results from the test are printed (default) or only the failing ones
     - error stack trace is printed
     - dbms_output from test run is always printed
  */
  overriding member procedure after_calling_test(a_test ut_test) as
    l_message varchar2(4000);

    procedure print_expectation(a_expectation ut_expectation_result) is
      l_lines  ut_varchar2_list;
      l_failed boolean := a_expectation.status > ut_utils.gc_success;
    begin
      if l_failed or self.report_all_expectations = 'Y' then
        l_lines := a_expectation.get_result_lines();
        for i in 1 .. l_lines.count loop
          if l_failed then
            self.print_red_text(l_lines(i));
          else
            self.print_green_text(l_lines(i));
          end if;
        end loop;
        self.print_cyan_text(a_expectation.caller_info);
        self.print_text(' ');
      end if;
    end;

    procedure print_results_for_test(a_test ut_test) is
    begin
      self.lvl := self.lvl + 3;
      self.print_red_text(ut_utils.table_to_clob( a_test.get_error_stack_traces() ));
      for j in 1 .. a_test.all_expectations.count loop
        print_expectation(a_test.all_expectations(j));
      end loop;
      self.lvl := self.lvl - 3;
    end;
  begin
    l_message := coalesce(a_test.description, a_test.name)||' ['||round(a_test.execution_time,3)||' sec]';
    --if test failed, then add it to the failures list, print failure with number
    if a_test.result = ut_utils.gc_disabled then
      self.print_yellow_text(l_message || ' (DISABLED)');
    elsif a_test.result = ut_utils.gc_success then
      self.print_green_text(l_message);
    elsif a_test.result > ut_utils.gc_success then
      self.failed_test_running_count := self.failed_test_running_count + 1;
      self.print_red_text(l_message || ' (FAILED - ' || failed_test_running_count || ')');
    end if;

    print_results_for_test(a_test);
    -- reproduce the output from before/after procedures and the test
    self.print_clob(a_test.get_serveroutputs);
  end;

  overriding member procedure after_calling_run(a_run in ut_run) as
    l_summary_text   varchar2(4000);
    l_warning_index pls_integer := 0;
    -- make all warning indexes uniformly indented
    c_warnings_lpad constant integer := length(to_char(a_run.results_count.warnings_count));

    procedure print_item_warnings(a_item in ut_suite_item) is
      l_items ut_suite_items;
    begin
      if a_item is of (ut_logical_suite) then
        l_items := treat(a_item as ut_logical_suite).items;
        for i in 1 .. l_items.count loop
          print_item_warnings(l_items(i));
        end loop;
      end if;

      if a_item.warnings is not null and a_item.warnings.count > 0 then
        for i in 1 .. a_item.warnings.count loop
          l_warning_index := l_warning_index + 1;
          self.print_text('  ' || lpad(l_warning_index, c_warnings_lpad) || ') ' || a_item.path);
          self.lvl := self.lvl + 3;
          self.print_red_text(a_item.warnings(i));
          self.lvl := self.lvl - 3;
        end loop;
        self.print_text(' ');
      end if;
    end;

    procedure print_warnings(a_run in ut_run) is
    begin
      if a_run.results_count.warnings_count > 0 then
        self.print_text(' ');
        self.print_text('Warnings:');
        self.print_text(' ');
        for i in 1 .. a_run.items.count loop
          print_item_warnings(treat(a_run.items(i) as ut_suite_item));
        end loop;
      end if;
    end;

  begin
    print_warnings(a_run);
    self.print_text('Finished in ' || a_run.execution_time || ' seconds');

    l_summary_text :=
      a_run.results_count.total_count || ' tests, '
      || a_run.results_count.failure_count || ' failed, ' || a_run.results_count.errored_count || ' errored, '
      || a_run.results_count.disabled_count ||' disabled, ' || a_run.results_count.warnings_count || ' warning(s)';
    if a_run.results_count.failure_count + a_run.results_count.errored_count + a_run.results_count.warnings_count > 0 then
      self.print_red_text(l_summary_text);
    else
      self.print_green_text(l_summary_text);
    end if;
    if a_run.random_test_order_seed is not null then
      self.print_text('Tests were executed with random order seed '''||a_run.random_test_order_seed||'''.');
    end if;
    self.print_text(' ');
    (self as ut_reporter_base).after_calling_run(a_run);
  end;

  overriding member function get_description return varchar2 as
  begin
    return 'A custom reporter for pretty-printing all expectation results directly under the test';
  end;

end;
/
