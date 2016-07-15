create or replace package body ut_types as

    
    function test_result_to_char(a_test_result test_result) return varchar2
    as
    begin
       case a_test_result
           when tr_success then return 'Success';
           when tr_failure then return 'Failure';
           when tr_error then return 'Error';
       end case; 
    end;
    
end ut_types;