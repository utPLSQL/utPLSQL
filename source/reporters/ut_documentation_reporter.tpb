create or replace type body ut_documentation_reporter is

  constructor function ut_documentation_reporter(self in out nocopy ut_documentation_reporter, a_output ut_output default ut_output_dbms_output()) return self as result is
  begin
    self.name               := $$plsql_unit;
    self.output             := a_output;
    self.lvl                := 0;
    self.failed_test_count  := 0;
    self.test_count         := 0;
    self.igonred_test_count := 0;
    return;
  end;

  member function tab(self in ut_documentation_reporter) return varchar2 is
  begin
    return rpad(' ', self.lvl * 2);
  end tab;

  overriding member procedure print_text(self in out nocopy ut_documentation_reporter, a_text varchar2) is
  begin
    if a_text is not null then
      (self as ut_reporter).print_text(tab || a_text);
    end if;
  end;

  overriding member procedure before_calling_suite(self in out nocopy ut_documentation_reporter, a_suite ut_suite) as
  begin
    self.print_text( coalesce( a_suite.description, a_suite.name ) );
    lvl := lvl + 1;
  end;

  overriding member procedure before_calling_test(self in out nocopy ut_documentation_reporter, a_test ut_test) as
  begin
    test_count := test_count + 1;
    if a_test.get_ignore_flag() then
      igonred_test_count := igonred_test_count + 1;
    end if;
  end;

  overriding member procedure after_calling_test(self in out nocopy ut_documentation_reporter, a_test ut_test) as
    l_message varchar2(4000);
  begin
    l_message := coalesce( a_test.description, a_test.name );
    --if test failed, then add it to the failures list, print failure with number
    if a_test.result > ut_utils.tr_success then
      failed_test_count := failed_test_count + 1;
      l_message := l_message || ' (FAILED - '||failed_test_count||')';
    end if;
    self.print_text( l_message );
  end;

  overriding member procedure after_calling_suite(self in out nocopy ut_documentation_reporter, a_suite ut_suite) as
  begin
    lvl := lvl - 1;
    if lvl = 0 then
      self.print_text(' ');
    end if;
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_documentation_reporter, a_run in ut_run) as
    l_start_time    timestamp with time zone := to_date('9999','yyyy');
    l_end_time      timestamp with time zone := to_date('0001','yyyy');

    procedure print_failure_for_assert(a_assert ut_assert_result) is
      l_lines ut_varchar2_list;
    begin
      l_lines := a_assert.get_result_lines();
      for i in 1 .. l_lines.count loop
        self.print_text(l_lines(i));
      end loop;
    end;

    procedure print_failures_for_test(a_test ut_test, a_failure_no in out nocopy integer) is
    begin
      if a_test.result > ut_utils.tr_success then
        a_failure_no := a_failure_no + 1;
        self.print_text(lpad(a_failure_no,  4,' ')||') '||coalesce( a_test.name, a_test.item.form_name ));
        self.lvl := self.lvl + 3;
        self.print_text('Failures/Errors:');
        for j in 1 .. a_test.results.count loop
          print_failure_for_assert(a_test.results(j));
        end loop;
        lvl := lvl - 3;
      end if;
    end;

    procedure print_failures_from_suite(a_suite ut_suite, a_failure_no in out nocopy integer) is
    begin
      for i in 1 .. a_suite.items.count loop
        if a_suite.items(i) is of (ut_suite) then
          print_failures_from_suite(treat( a_suite.items(i) as ut_suite), a_failure_no);
        elsif a_suite.items(i) is of (ut_test) then
          print_failures_for_test(treat(a_suite.items(i) as ut_test), a_failure_no);
        end if;
      end loop;
    end;

    procedure print_failures_details(a_suites in ut_suite_items) is
      l_failure_no integer := 0;
    begin
      if failed_test_count > 0 then

        self.print_text( 'Failures:' );
        self.print_text( ' ' );
        for i in 1 .. a_suites.count loop
          print_failures_from_suite(treat(a_suites(i) as ut_suite), l_failure_no);
        end loop;
      end if;
    end;

  begin
    print_failures_details(a_run.items);
    self.print_text( 'Finished in '||a_run.execution_time||' seconds' );
    self.print_text(
      test_count || ' tests' ||
      case
        when failed_test_count = 1 then ', '||failed_test_count||' failure'
        else ', '||failed_test_count||' failures'
      end ||
      case
        when igonred_test_count > 0 then ', '||igonred_test_count||' ignored'
      end
    );
    self.print_text(' ');
    (self as ut_reporter).after_calling_run(a_run);
  end;

end;
/
