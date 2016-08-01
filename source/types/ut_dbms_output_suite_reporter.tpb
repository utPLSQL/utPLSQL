create or replace type body ut_dbms_output_suite_reporter is

  static function c_dashed_line return varchar2 is
  begin
    return lpad('-',80,'-');
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

  overriding member procedure begin_suite(self in out nocopy ut_dbms_output_suite_reporter, a_suite_name in varchar2) as
  begin
    print(ut_dbms_output_suite_reporter.c_dashed_line);
    print('suite "' || a_suite_name || '" started.');
  end;

  overriding member procedure end_suite(self in out nocopy ut_dbms_output_suite_reporter, a_suite_name in varchar2, a_suite_execution_result in ut_execution_result) as
  begin
    --todo: report total suite result here with pretty message
    print(ut_dbms_output_suite_reporter.c_dashed_line);
    print('suite "' || a_suite_name || '" ended.');
    print(ut_dbms_output_suite_reporter.c_dashed_line);
  end;

  overriding member procedure begin_test(self in out nocopy ut_dbms_output_suite_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params) as
  begin
    print(ut_dbms_output_suite_reporter.c_dashed_line);
    if a_test_name is not null then
      print('test  ' || a_test_name || ' (' ||
            ut_metadata.form_name(a_test_call_params.owner_name
                                 ,a_test_call_params.object_name
                                 ,a_test_call_params.test_procedure) || ')');
    else
      print('test  ' || ut_metadata.form_name(a_test_call_params.owner_name
                                             ,a_test_call_params.object_name
                                             ,a_test_call_params.test_procedure));
    end if;
  end;

  overriding member procedure end_test(self in out nocopy ut_dbms_output_suite_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params, a_execution_result in ut_execution_result, a_assert_list in ut_assert_list) as
  begin
    print('result: ' || a_execution_result.result_to_char);
    print('asserts');
    for i in a_assert_list.first .. a_assert_list.last loop
      print('assert ' || i || ' ' || a_assert_list(i).result_to_char || ' message: ' || a_assert_list(i).message);
    end loop;
  end;

end;
/
