create or replace package body ut_utils is

  function test_result_to_char(a_test_result integer) return varchar2 as
  begin
    return case a_test_result
                  when tr_success then tr_success_char
                  when tr_failure then tr_failure_char
                  when tr_error   then tr_error_char
                  else 'Unknown(' || coalesce(to_char(a_test_result),'NULL') || ')'
                end;
  end test_result_to_char;

end ut_utils;
/
