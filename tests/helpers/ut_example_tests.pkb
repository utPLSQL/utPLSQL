create or replace package body ut_example_tests
as

 procedure setup as
 begin
   g_number := 0;
 end;

 procedure teardown
 as
 begin
    g_char := null;
 end;

 procedure ut_passing_test
 as
 begin
    g_number := g_number + 1;
    g_char := 'a';
    ut.expect(1,'Test 1 Should Pass').to_equal(1);
 end;

end;
/
