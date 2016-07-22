create or replace type body ut_execution_result is

  constructor function ut_execution_result(a_start_time timestamp with time zone default current_timestamp)
    return self as result is
  begin
    self.start_time := a_start_time;
    self.result := ut_utils.tr_success;
    return;
  end ut_execution_result;

  member function result_to_char(self in ut_execution_result) return varchar2 is
  begin
    return ut_utils.test_result_to_char(self.result);
  end result_to_char;

end;
/
