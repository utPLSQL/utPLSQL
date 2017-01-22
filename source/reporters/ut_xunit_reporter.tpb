create or replace type body ut_xunit_reporter is

  constructor function ut_xunit_reporter(a_output ut_output default ut_output_buffered()) return self as result is
  begin
    self.name   := $$plsql_unit;
    self.output := a_output;
    return;
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_xunit_reporter, a_run in ut_run) is
    l_suite_id    integer := 0;
    l_tests_count integer := a_run.results_count.ignored_count + a_run.results_count.success_count + a_run.results_count.failure_count + a_run.results_count.errored_count;

    function get_path(a_path_with_name varchar2, a_name varchar2) return varchar2 is
    begin
      return substr(a_path_with_name, 1, instr(a_path_with_name,'.'||a_name)-1);
    end;

    procedure print_test_elements(a_test ut_test) is
    begin
      self.print_text(
          '<testcase classname="'||get_path(a_test.path, a_test.name)||'" ' ||
          ' assertions="'||coalesce(cardinality(a_test.results),0)||'"' ||
          self.get_common_item_attributes(a_test) ||
          ' status="'||ut_utils.test_result_to_char(a_test.result)||'"' ||
          '>'
      );
      if a_test.result = ut_utils.tr_ignore then
        self.print_text('<skipped/>');
      end if;

      if a_test.result > ut_utils.tr_success then
        self.print_text('<failure>');
        self.print_text( '<![CDATA[');
        for i in 1 .. a_test.results.count loop
          self.print_text( a_test.results(i).get_result_clob);
        end loop;
        self.print_text(']]>');
        self.print_text('</failure>');
      end if;
      --    TODO - separate failure messages, error messages, and dbms_output results from tests execution
      --    TODO - decide if to use 'skipped' or 'disabled'
      --    <error message="" type=""/>
      --    <system-out/>
      --    <system-err/>
      self.print_text('</testcase>');
    end;

    procedure print_suite_elements(a_suite ut_logical_suite, a_suite_id in out nocopy integer) is
      l_tests_count integer := a_suite.results_count.ignored_count + a_suite.results_count.success_count + a_suite.results_count.failure_count + a_suite.results_count.errored_count;
    begin
      a_suite_id := a_suite_id + 1;
      self.print_text(
          '<testsuite tests="' || l_tests_count || '"' || ' id="' || a_suite_id || '"' ||
          ' package="' || a_suite.path || '" ' || self.get_common_item_attributes(a_suite) || '>'
      );
      --    TODO - separate failure messages, error messages, and dbms_output results from tests execution
      --    TODO - decide if to use 'skipped' or 'disabled'
      --    <system-out/>
      --    <system-err/>
      for i in 1 .. a_suite.items.count loop
        if a_suite.items(i) is of (ut_test) then
          print_test_elements(treat(a_suite.items(i) as ut_test));
        elsif a_suite.items(i) is of (ut_logical_suite) then
          print_suite_elements(treat(a_suite.items(i) as ut_logical_suite), a_suite_id);
        end if;
      end loop;
      self.print_text('</testsuite>');
    end;
  begin
    l_suite_id := 0;
    self.print_text('<testsuites tests="'||l_tests_count||'"'||self.get_common_item_attributes(a_run)||'>');
    for i in 1 .. a_run.items.count loop
      print_suite_elements(treat(a_run.items(i) as ut_logical_suite), l_suite_id);
    end loop;
    self.print_text('</testsuites>');
    (self as ut_reporter_base).after_calling_run(a_run);
  end;

  member function get_common_item_attributes(a_item ut_suite_item) return varchar2 is
  begin
    return
      ' skipped="'||a_item.results_count.ignored_count||'" error="'||a_item.results_count.errored_count||'"'||
      ' failure="'||a_item.results_count.failure_count||'" name="'||a_item.description||'"'||
      ' time="'||a_item.execution_time()||'" ';
  end;

end;
/
