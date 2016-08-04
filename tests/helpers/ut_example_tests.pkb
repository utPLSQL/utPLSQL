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
    ut_assert.are_equal('Test 1 Should Pass',1,1);
 end;
 
end;
/
