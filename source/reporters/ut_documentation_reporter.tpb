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
    (self as ut_reporter).print_text(tab || a_text);
  end;

  overriding member procedure before_suite(self in out nocopy ut_documentation_reporter, a_suite ut_suite_item) as
  begin
    self.print_text( coalesce( a_suite.description, a_suite.name ) );
    lvl := lvl + 1;
  end;

  overriding member procedure before_test(self in out nocopy ut_documentation_reporter, a_test ut_suite_item) as
  begin
    test_count := test_count + 1;
    if treat(a_test as ut_suite_item).get_ignore_flag() then
      igonred_test_count := igonred_test_count + 1;
    end if;
  end;

  overriding member procedure after_test(self in out nocopy ut_documentation_reporter, a_test ut_suite_item) as
    l_test    ut_test := treat(a_test as ut_test);
    l_message varchar2(4000);
  begin
    l_message := coalesce( a_test.description, l_test.name );
    --if test failed, then add it to the failures list, print failure with number
    if a_test.result != ut_utils.tr_success then
      failed_test_count := failed_test_count + 1;
      l_message := l_message || ' (FAILED - '||failed_test_count||')';
    end if;
    self.print_text( l_message );
  end;

  overriding member procedure after_suite(self in out nocopy ut_documentation_reporter, a_suite ut_suite_item) as
  begin
    lvl := lvl - 1;
    if lvl = 0 then
      self.print_text(' ');
    end if;
  end;

  overriding member procedure after_run(self in out nocopy ut_documentation_reporter, a_suites in ut_suite_items) as
    l_start_time    timestamp with time zone := to_date('9999','yyyy');
    l_end_time      timestamp with time zone := to_date('0001','yyyy');

    procedure print_failure_for_assert(a_assert ut_assert_result) is
    begin
      if a_assert.result != ut_utils.tr_success then
        if a_assert.message is not null then
          self.print_text('message: '||a_assert.message);
        end if;
        if a_assert.result != ut_utils.tr_success then
          if a_assert.actual_value_string is not null or a_assert.actual_type is not null then
            self.print_text('expected: '||ut_utils.indent_lines( a_assert.actual_value_string||'('||a_assert.actual_type||')', self.lvl*2+length('expected: ') ) );
          end if;
          if a_assert.name is not null or a_assert.additional_info is not null
             or a_assert.expected_value_string is not null or a_assert.expected_type is not null then
            self.print_text(
              a_assert.name || a_assert.additional_info
              || case
                   when a_assert.expected_value_string is not null or a_assert.expected_type is not null
                   then ': '||ut_utils.indent_lines( a_assert.expected_value_string||'('||a_assert.expected_type||')', self.lvl*2+length(a_assert.name || a_assert.additional_info||': ') )
                 end
            );
          end if;
        end if;
        if a_assert.error_message is not null then
          self.print_text('error: '||ut_utils.indent_lines( a_assert.error_message, self.lvl*2+length('error: ') ) );
        end if;
        if a_assert.caller_info is not null then
          self.print_text(a_assert.caller_info);
        end if;
        self.print_text(' ');
      end if;
    end;

    procedure print_failures_for_test(a_test ut_test, a_failure_no in out nocopy integer) is
    begin
      if a_test.result > ut_utils.tr_success then
        a_failure_no := a_failure_no + 1;  
        self.print_text(lpad(a_failure_no,  4,' ')||') '||coalesce( a_test.name, a_test.item.form_name ));
        self.lvl := self.lvl + 3;
        self.print_text('Failures/Errors:');
        self.lvl := self.lvl + 1;
        for j in 1 .. a_test.results.count loop
          print_failure_for_assert(a_test.results(j));
        end loop;
        lvl := lvl - 4;
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
        for i in 1 .. a_suites.count loop
          print_failures_from_suite(treat(a_suites(i) as ut_suite), l_failure_no);
        end loop;
      end if;
    end;
    
  begin
    print_failures_details(a_suites);
    for i in 1 .. a_suites.count loop
      l_start_time := least(l_start_time, a_suites(i).start_time);
      l_end_time := greatest(l_end_time, a_suites(i).end_time);
    end loop;
    self.print_text( 'Finished in '||ut_utils.to_string(ut_utils.time_diff(l_start_time, l_end_time))||' seconds' );
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
    (self as ut_reporter).after_run(a_suites);
  end;

end;
/
