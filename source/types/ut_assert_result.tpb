create or replace type body ut_assert_result is
  
  member function result_to_char(self in ut_assert_result) return varchar2 is
  begin
    return ut_utils.test_result_to_char(result);
  end;
  
end;
/
