create or replace type body ut_dbms_output_suite_reporter is

  static function c_dashed_line return varchar2 is
  begin
    return lpad('-', 80, '-');
  end;

  constructor function ut_dbms_output_suite_reporter return self as result is
  begin
    self.name := $$plsql_unit;
    return;
  end;

  member procedure print(msg varchar2) is
  begin
    dbms_output.put_line(msg);
  end print;

  overriding member procedure before_suite(self in out nocopy ut_dbms_output_suite_reporter, a_suite ut_object) as
  begin
    print(ut_dbms_output_suite_reporter.c_dashed_line);
    print('suite "' || a_suite.name || '" started.');
  end;

  overriding member procedure before_test(self in out nocopy ut_dbms_output_suite_reporter, a_test ut_object) as
    test ut_test := treat(a_test as ut_test);
  begin
    print(ut_dbms_output_suite_reporter.c_dashed_line);
    if a_test.name is not null then
      print('test  ' || test.name || ' (' || test.test.form_name || ')');
    else
      print('test  ' || test.test.form_name);
    end if;
  end;

  overriding member procedure on_assert_process(self in out nocopy ut_dbms_output_suite_reporter, a_assert ut_object) as
    l_assert ut_assert_result := treat(a_assert as ut_assert_result);
  begin
    if l_assert is not null then
      if l_assert.message is not null then
        print('message: '||l_assert.message);
      end if;
      if l_assert.result != ut_utils.tr_success then
        print('expected: ' || l_assert.actual_value_string||'('||l_assert.actual_type||')');
        print(
          l_assert.name
          || case
               when l_assert.expected_value_string is not null or l_assert.expected_type is not null
               then ': '||l_assert.expected_value_string||'('||l_assert.expected_type||')'
             end
        );
        print(l_assert.result_to_char());
      end if;
    end if;
  end;

  overriding member procedure after_test(self in out nocopy ut_dbms_output_suite_reporter, a_test ut_object) as
    l_test     ut_test_object := treat(a_test as ut_test);
    l_duration interval day(0) to second(6) := (l_test.end_time - l_test.start_time);
  begin
    print('result: ' || l_test.result_to_char||'. Took: '||to_char(l_duration));
  end;

  overriding member procedure after_suite(self in out nocopy ut_dbms_output_suite_reporter, a_suite ut_object) as
    l_suite    ut_test_object := treat(a_suite as ut_test_object);
    l_duration interval day(0) to second(6) := (l_suite.end_time - l_suite.start_time);
  begin
    --todo: report total suite result here with pretty message
    print(ut_dbms_output_suite_reporter.c_dashed_line);
    print('suite "' || l_suite.name || '" ended. Took: '||to_char(l_duration));
    print(ut_dbms_output_suite_reporter.c_dashed_line);
  end;

  overriding member procedure before_asserts_process(self in out nocopy ut_dbms_output_suite_reporter, a_test in ut_object) as
  begin
    null;
  end;


end;
/
