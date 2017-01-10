create or replace package test_pkg2 is

  /*
  This is the correct annotation
  */
  -- %suite
  -- %displayname(Name of suite on test_pkg2)
  -- %suitepath(all)

  -- %test
  -- %displayname(Name of test1)
  procedure test1;

  -- %test
  -- %displayname(Name of test2)
  procedure test2;

end;
/
create or replace package body test_pkg2 is

  procedure test1 is
  begin
    ut.expect(1,'1 equals 1 check').to_equal(1);
  end;

  procedure test2 is
  begin
    ut.expect(2,'2 equals 2 check').to_equal(2);
  end;

end test_pkg2;
/
