create or replace type body ut_documentation_reporter is
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

  constructor function ut_documentation_reporter(self in out nocopy ut_documentation_reporter) return self as result is
  begin
    self.init($$plsql_unit);
    self.lvl                       := 0;
    self.failed_test_running_count := 0;
    return;
  end;

  member function tab(self in ut_documentation_reporter) return varchar2 is
  begin
    return rpad(' ', self.lvl * 2);
  end tab;

  overriding member procedure print_text(self in out nocopy ut_documentation_reporter, a_text varchar2) is
  begin
    if a_text is not null then
      (self as ut_reporter_base).print_text(tab || a_text);
    end if;
  end;

  overriding member procedure before_calling_suite(self in out nocopy ut_documentation_reporter, a_suite ut_logical_suite) as
  begin
    self.print_text( coalesce( a_suite.description, a_suite.name ) );
    lvl := lvl + 1;
  end;

  overriding member procedure after_calling_test(self in out nocopy ut_documentation_reporter, a_test ut_test) as
    l_message varchar2(4000);
    
    procedure print_output(a_exectable ut_executable) is
      l_lines ut_varchar2_list;
    begin
      if a_exectable is not null and a_exectable.is_defined and a_exectable.serveroutput is not null and dbms_lob.getlength(a_exectable.serveroutput) > 0 then
        l_lines := ut_utils.clob_to_table(a_exectable.serveroutput);
        for i in 1..l_lines.count loop
          self.print_text(l_lines(i));
        end loop;
      end if;
    end;
  begin
    l_message := coalesce( a_test.description, a_test.name );
    --if test failed, then add it to the failures list, print failure with number
    if a_test.result = ut_utils.tr_ignore then
      self.print_yellow_text(l_message || ' (IGNORED)');
    elsif a_test.result = ut_utils.tr_success then
      self.print_green_text(l_message);
    elsif a_test.result > ut_utils.tr_success then
      failed_test_running_count := failed_test_running_count + 1;
      self.print_red_text(l_message || ' (FAILED - '||failed_test_running_count||')');
    end if;
    
    -- reproduce the output from before/after procedures and the test
    print_output(a_test.before_each);
    print_output(a_test.before_test);
    print_output(a_test.item);
    print_output(a_test.after_test);
    print_output(a_test.after_each);
  end;

  overriding member procedure after_calling_suite(self in out nocopy ut_documentation_reporter, a_suite ut_logical_suite) as
  begin
    lvl := lvl - 1;
    if lvl = 0 then
      self.print_text(' ');
    end if;
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_documentation_reporter, a_run in ut_run) as
    l_summary_text varchar2(4000);
    l_warnings ut_varchar2_list := ut_varchar2_list();
    procedure print_failure_for_assert(a_assert ut_assert_result) is
      l_lines ut_varchar2_list;
    begin
      l_lines := a_assert.get_result_lines();
      for i in 1 .. l_lines.count loop
        self.print_red_text(l_lines(i));
      end loop;
      self.print_cyan_text(a_assert.caller_info);
      self.print_text(' ');
    end;

    procedure print_failures_for_test(a_test ut_test, a_failure_no in out nocopy integer) is
    begin
      if a_test.result > ut_utils.tr_success then
        a_failure_no := a_failure_no + 1;
        self.print_text(lpad(a_failure_no, length(failed_test_running_count)+2,' ')||') '||nvl( a_test.name, a_test.item.form_name ));
        self.lvl := self.lvl + 3;
        for j in 1 .. a_test.results.count loop
          if a_test.results(j).result > ut_utils.tr_success then
            print_failure_for_assert(a_test.results(j));
          end if;
        end loop;
        lvl := lvl - 3;
      end if;
    end;

    procedure print_failures_from_suite(a_suite ut_logical_suite, a_failure_no in out nocopy integer) is
    begin
      for i in 1 .. a_suite.items.count loop
        if a_suite.items(i) is of (ut_logical_suite) then
          print_failures_from_suite(treat( a_suite.items(i) as ut_logical_suite), a_failure_no);
        elsif a_suite.items(i) is of (ut_test) then
          print_failures_for_test(treat(a_suite.items(i) as ut_test), a_failure_no);
        end if;
      end loop;
    end;

    procedure print_failures_details(a_run in ut_run) is
      l_failure_no integer := 0;
    begin
      if a_run.results_count.failure_count > 0 or a_run.results_count.errored_count > 0 then

        self.print_text( 'Failures:' );
        self.print_text( ' ' );
        for i in 1 .. a_run.items.count loop
          print_failures_from_suite(treat(a_run.items(i) as ut_logical_suite), l_failure_no);
        end loop;
      end if;
    end;
    
    procedure print_warnings(a_run in ut_run) is     
      procedure gather_warnings(a_item ut_suite_item) is
        l_suite ut_logical_suite;
      begin
        --process warnings of child items first
        if a_item is of(ut_logical_suite) then
          l_suite := treat(a_item as ut_logical_suite);
          for item_ind in 1..l_suite.items.count loop
            gather_warnings(l_suite.items(item_ind));
          end loop;
        end if;
        
        --then process self warnings
        if a_item.warnings is not null and a_item.warnings.count > 0 then
          for warn_ind in 1..a_item.warnings.count loop
            l_warnings.extend;
            l_warnings(l_warnings.last) := '  '||l_warnings.last||') '||a_item.path||' - '||
            regexp_replace(a_item.warnings(warn_ind),'('||chr(10)||'|'||chr(13)||')','\1       ');
          end loop;
        end if;
      end;
    begin
      if a_run.items is not null and a_run.items.count >0 then
        for run_item in 1..a_run.items.count loop
          gather_warnings(a_run.items(run_item));
        end loop;
      end if;
      
      if l_warnings.count>0 then
        self.print_text( 'Warnings:' );
        self.print_text( ' ' );
        for i in 1 .. l_warnings.count loop
          self.print_text(l_warnings(i));
          self.print_text(' ');
        end loop;
      end if;
    end;

  begin
    print_failures_details(a_run);
    print_warnings(a_run);
    self.print_text( 'Finished in '||a_run.execution_time||' seconds' );
    l_summary_text :=
      a_run.results_count.total_count || ' tests, '
      ||a_run.results_count.failure_count||' failed, '
      ||a_run.results_count.errored_count||' errored, '
      ||a_run.results_count.ignored_count||' ignored.'||
      case when l_warnings.count>0 then ' '||l_warnings.count||' warning(s)' end;
    if a_run.results_count.failure_count > 0 then
      self.print_red_text(l_summary_text);
    else
      self.print_green_text(l_summary_text);
    end if;
    self.print_text(' ');
    (self as ut_reporter_base).after_calling_run(a_run);
  end;

end;
/
