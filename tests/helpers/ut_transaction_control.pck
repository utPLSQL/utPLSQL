create or replace package ut_transaction_control as

  function count_rows(a_val varchar2) return number;

  procedure setup;

  procedure test;
  
  procedure test_failure;

end;
/
create or replace package body ut_transaction_control
as 

  function count_rows(a_val varchar2) return number is
    l_cnt number;
  begin
    select count(*) 
      into l_cnt 
      from ut$test_table t
     where t.val = a_val;
     
    return l_cnt;
  end;

  procedure setup is begin
    insert into ut$test_table values ('s');
  end;
  
  procedure test is
  begin
    insert into ut$test_table values ('t');
  end;
  
  procedure test_failure is
  begin
    insert into ut$test_table values ('t');
    --raise no_data_found;
    raise_application_error(-20001,'Error');
  end;
    
end;
/
