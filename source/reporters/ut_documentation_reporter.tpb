create or replace type body ut_documentation_reporter is

  constructor function ut_documentation_reporter(self in out nocopy ut_documentation_reporter, a_output ut_output default ut_output_dbms_output()) return self as result is
  begin
    self.name               := $$plsql_unit;
    self.output             := a_output;
    self.lvl                := 0;
    self.failed_tests       := ut_objects_list();
    self.test_count         := 0;
    self.igonred_test_count := 0;
    return;
  end;

  member function tab(self in ut_documentation_reporter) return varchar2 is
  begin
    return rpad(' ', self.lvl * 2);
  end tab;

  overriding member procedure print(self in out nocopy ut_documentation_reporter, a_text varchar2) is
  begin
    (self as ut_reporter).print(tab || a_text);
  end print;

  overriding member procedure before_suite(self in out nocopy ut_documentation_reporter, a_suite ut_object) as
    l_suite ut_test_suite := treat(a_suite as ut_test_suite);
  begin
    self.print( coalesce( a_suite.name, l_suite.object_name ) );
    lvl := lvl + 1;
  end;

  overriding member procedure before_test(self in out nocopy ut_documentation_reporter, a_test ut_object) as
  begin
    test_count := test_count + 1;
    if treat(a_test as ut_test).get_ignore_flag() then
      igonred_test_count := igonred_test_count + 1;
    end if;
  end;
  overriding member procedure after_test(self in out nocopy ut_documentation_reporter, a_test ut_object) as
    l_test    ut_test := treat(a_test as ut_test);
    l_message varchar2(4000);
  begin
    l_message := coalesce( l_test.name, l_test.test.form_name );
    --if test failed, then add it to the failures list, print failure with number
    if l_test.result != ut_utils.tr_success then
      failed_tests.extend;
      failed_tests(failed_tests.last) := l_test;
      l_message := l_message || ' (FAILED - '||failed_tests.last||')';
    end if;
    self.print( l_message );
  end;

  overriding member procedure after_suite(self in out nocopy ut_documentation_reporter, a_suite ut_object) as
    l_suite ut_test_suite := treat(a_suite as ut_test_suite);
  begin
    lvl := lvl - 1;
    self.print( ' ' );
  end;

  overriding member procedure after_run(self in out nocopy ut_documentation_reporter, a_suites in ut_objects_list) as
    l_start_time    timestamp with time zone := to_date('9999','yyyy');
    l_end_time      timestamp with time zone := to_date('0001','yyyy');
    procedure print_failures_summary is
      l_assert     ut_assert_result;
      l_test       ut_test;
    begin
      if failed_tests.count > 0 then

        self.print( 'Failures:' );

        for i in 1 .. failed_tests.count loop
          l_test := treat(failed_tests(i) as ut_test);
          self.print(lpad(i,  4,' ')||') '||coalesce( l_test.name, l_test.test.form_name ));
          lvl := lvl + 3;
          self.print('Failures/Errors:');
          lvl := lvl + 1;
          for j in 1 .. l_test.items.count loop
            l_assert := treat(l_test.items(j) as ut_assert_result);
            if l_assert.result != ut_utils.tr_success then
              if l_assert.message is not null then
                self.print('message: '||l_assert.message);
              end if;
              if l_assert.result != ut_utils.tr_success then
                if l_assert.actual_value_string is not null or l_assert.actual_type is not null then
                  self.print('expected: '||ut_utils.indent_lines( l_assert.actual_value_string||'('||l_assert.actual_type||')', self.lvl*2+length('expected: ') ) );
                end if;
                if l_assert.name is not null or l_assert.additional_info is not null
                   or l_assert.expected_value_string is not null or l_assert.expected_type is not null then
                  self.print(
                    l_assert.name || l_assert.additional_info
                    || case
                         when l_assert.expected_value_string is not null or l_assert.expected_type is not null
                         then ': '||ut_utils.indent_lines( l_assert.expected_value_string||'('||l_assert.expected_type||')', self.lvl*2+length(l_assert.name || l_assert.additional_info||': ') )
                       end
                  );
                end if;
              end if;
              if l_assert.error_message is not null then
                self.print('error: '||ut_utils.indent_lines( l_assert.error_message, self.lvl*2+length('error: ') ) );
              end if;
              if l_assert.caller_info is not null then
                self.print(l_assert.caller_info);
              end if;
              self.print('');
            end if;
          end loop;
          lvl := lvl - 4;
        end loop;
      end if;
    end;
  begin
    print_failures_summary();
    for i in 1 .. a_suites.count loop
      l_start_time := least(l_start_time, treat(a_suites(i) as ut_test_object).start_time);
      l_end_time := greatest(l_end_time, treat(a_suites(i) as ut_test_object).end_time);
    end loop;
    self.print( 'Finished in '||ut_utils.to_string(ut_utils.time_diff(l_start_time, l_end_time))||' seconds' );
    self.print(
      test_count || ' tests' ||
      case
        when failed_tests.count > 1 then ', '||failed_tests.count||' failures'
        when failed_tests.count > 0 then ', '||failed_tests.count||' failure'
      end ||
      case
        when igonred_test_count > 0 then ', '||igonred_test_count||' ignored'
      end
    );
  end;

end;
/
