--https://docs.oracle.com/database/sql-developer-4.2/RPTUG/sql-developer-unit-testing.htm#RPTUG45065


create or replace procedure award_bonus (emp_id number, sales_amt number) as
  commission    real;
  comm_missing  exception;
begin
  select commission_pct into commission
    from employees_test
      where employee_id = emp_id;

  if commission is null then
    raise comm_missing;
  else
    update employees_test
      set salary = nvl(salary,0) + sales_amt*commission
        where employee_id = emp_id;
  end if;
end;
/
