create or replace type body ut_dbms_output_suite_reporter is

  static function c_dashed_line return varchar2 is
  begin
    return '--------------------------------------------------------------------------------';
  end;

  constructor function ut_dbms_output_suite_reporter return self as result is
  begin
    self.name := $$plsql_unit;
  end;

  overriding member procedure begin_suite(self in ut_dbms_output_suite_reporter, a_suite_name in varchar2) as
  begin
    dbms_output.put_line(ut_dbms_output_suite_reporter.c_dashed_line);
    dbms_output.put_line('suite "' || a_suite_name || '" started.');
  end;

  overriding member procedure end_suite(self in ut_dbms_output_suite_reporter, a_suite_name in varchar2, a_suite_execution_result in ut_execution_result) as
  begin
    --todo: report total suite result here with pretty message
    dbms_output.put_line(ut_dbms_output_suite_reporter.c_dashed_line);
    dbms_output.put_line('suite "' || a_suite_name || '" ended.');
    dbms_output.put_line(ut_dbms_output_suite_reporter.c_dashed_line);
  end;

  overriding member procedure begin_test(self in ut_dbms_output_suite_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params) as
  begin
    null;
  end;

  overriding member procedure end_test(self in ut_dbms_output_suite_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params, a_execution_result in ut_execution_result, a_assert_list in ut_assert_list) as
  begin
    dbms_output.put_line(ut_dbms_output_suite_reporter.c_dashed_line);
    dbms_output.put_line('test  ' || nvl(a_test_call_params.owner_name, '') || nvl(a_test_call_params.object_name, '') || '.' ||
                         nvl(a_test_call_params.test_procedure, ''));
    dbms_output.put_line('result: ' || a_execution_result.result_to_char);
    dbms_output.put_line('asserts');
    for i in a_assert_list.first .. a_assert_list.last loop
      dbms_output.put('assert ' || i || ' ' || a_assert_list(i).result_to_char);
      dbms_output.put_line(' message: ' || a_assert_list(i).message);
    end loop;
  end;

end;
/
