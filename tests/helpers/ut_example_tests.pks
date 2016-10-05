create or replace package ut_example_tests as
  -- %suite(An example test sute)
  g_number  number;
  g_char    varchar2(1);

  -- %setup(dumm=value,another=dummy value)
  procedure setup;

  -- %teardown
  procedure teardown;

  -- %test(An example of a passing test)
  procedure ut_passing_test;
end;
/
