create or replace package body ut_utils is

  function test_result_to_char(a_test_result integer) return varchar2 as
    v_result varchar2(250);
  begin
  
    v_result := case a_test_result
                  when tr_success then
                   'Success'
                  when tr_failure then
                   'Failure'
                  when tr_error then
                   'Error'
                  else
                   'Unknown(' || a_test_result || ')'
                end;
    return v_result;
  end test_result_to_char;

end ut_utils;
/
