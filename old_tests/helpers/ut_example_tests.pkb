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
 
 procedure beforeeach as
 begin
   g_number2 := 0;
 end;

 procedure aftereach
 as
 begin
    g_char2 := 'F';
 end;

 procedure ut_passing_test
 as
 begin
    g_number := g_number + 1;
    g_number2 := g_number2 + 1;
    g_char := 'a';
    g_char2 := 'a';
    ut.expect(1,'Test 1 Should Pass').to_equal(1);
 end;
 
 procedure ut_commit_test 
 is
 begin
   commit;
 end;

end;
/
