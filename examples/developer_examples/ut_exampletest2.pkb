create or replace package body ut_exampletest2
AS

 procedure Setup
 as
 begin
   null;
 end;

 procedure TearDown
 as
 begin
   null;
 end;

 procedure ut_exampletest
 as
 begin
    ut.expect(1,'Test 1 Should Pass').to_equal(1);
    ut.expect(2,'Test 2 Should Pass').to_equal(2);
 end;

END;
/
