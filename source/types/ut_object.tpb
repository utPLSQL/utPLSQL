create or replace type body ut_object is

  member function result_to_char return varchar2 is
  begin
    return ut_utils.test_result_to_char(self.result);
  end;

end;
/
