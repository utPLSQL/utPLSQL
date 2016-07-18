create or replace package body ut_types as

  function test_result_to_char(a_test_result integer) return varchar2 as
  begin
    case a_test_result
      when tr_success then
        return 'Success';
      when tr_failure then
        return 'Failure';
      when tr_error then
        return 'Error';
      else
        return 'Unknown(' || a_test_result || ')';
    end case;
  end;


end ut_types;
/
