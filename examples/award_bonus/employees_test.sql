create table employees_test (employee_id number primary key, commission_pct number, salary number);
insert into employees_test values (1001, 0.2, 8400);
insert into employees_test values (1002, 0.25, 6000);
insert into employees_test values (1003, 0.3, 5000);
-- next employee is not in the sales department, thus is not on commission.
insert into employees_test values (1004, null, 10000);
commit;
