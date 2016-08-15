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

  overriding member procedure begin_suite(self in out nocopy ut_dbms_output_suite_reporter, a_suite ut_object) as
  begin
    print(ut_dbms_output_suite_reporter.c_dashed_line);
    print('suite "' || a_suite.name || '" started.');
  end;

  overriding member procedure end_suite(self in out nocopy ut_dbms_output_suite_reporter, a_suite ut_object) as
  begin
    --todo: report total suite result here with pretty message
    print(ut_dbms_output_suite_reporter.c_dashed_line);
    print('suite "' || a_suite.name || '" ended.');
    print(ut_dbms_output_suite_reporter.c_dashed_line);
  end;

  overriding member procedure on_assert(self in out nocopy ut_dbms_output_suite_reporter, a_assert ut_object) as
  begin
    --todo: report total suite result here with pretty message
    null;
  end;

  overriding member procedure begin_test(self in out nocopy ut_dbms_output_suite_reporter, a_test ut_object) as
    test ut_test := treat(a_test as ut_test);
  begin
    print(ut_dbms_output_suite_reporter.c_dashed_line);
    if a_test.name is not null then
      print('test  ' || test.name || ' (' || test.test.form_name || ')');
    else
      print('test  ' || test.test.form_name);
    end if;
  end;

  overriding member procedure end_test(self in out nocopy ut_dbms_output_suite_reporter, a_test ut_object) as
    test   ut_test := treat(a_test as ut_test);
    assert ut_assert_result;
  begin
    print('result: ' || test.result_to_char);
    print('asserts');
    for i in test.items.first .. test.items.last loop
      assert := treat(test.items(i) as ut_assert_result);
      print('assert ' || i || ' ' || assert.result_to_char || ' message: ' || assert.message);
    end loop;
  end;

end;
/
