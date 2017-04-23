create or replace package test_reporters
as
  --%suite(A suite for testing different outcomes from reporters)

  --%beforeall
  procedure beforeall;

  --%beforeeach
  procedure beforeeach;

  --%test
  --%beforetest(beforetest)
  --%aftertest(aftertest)
  procedure passing_test;

  procedure beforetest;

  procedure aftertest;

  --%test(a test with failing assertion)
  procedure failing_test;

  --%test(a test raising unhandled exception)
  procedure erroring_test;

  --%test(a disabled test)
  --%disabled
  procedure disabled_test;

  --%aftereach
  procedure aftereach;

  --%afterall
  procedure afterall;

end;
/
