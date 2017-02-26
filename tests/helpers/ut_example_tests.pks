create or replace package ut_example_tests
as
 g_number  number;
 g_char    varchar2(1);
 procedure setup;
 procedure teardown;
 procedure ut_passing_test;
 procedure ut_commit_test;
end;
/
