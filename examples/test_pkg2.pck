create or replace package test_pkg2 is

  /*
  This is the correct annotation
  */
  -- %suite(Name of suite on test_pkg2)
  -- %suitepackage(all)

  -- %test(Name of test1)
  procedure test1;

  -- %test(Name of test2)
  procedure test2;

end;
/
create or replace package body test_pkg2 is

  procedure test1 is
  begin
    ut_assert.are_equal(a_msg => '1 equals 1 check', a_expected => 1, a_actual => 1);
  end;

  procedure test2 is
  begin
    ut_assert.are_equal(a_msg => '2 equals 2 check', a_expected => 2, a_actual => 2);
  end;

end test_pkg2;
/
