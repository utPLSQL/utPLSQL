create or replace package test_demo_package is

  --%suite

  --%test(A passing test)
  procedure success_test;

  --%test(A failing test)
  procedure failing_test;

  --%test(A test raising exception)
  procedure erroring_test;

  --%test(A disabled test)
  --%disabled
  procedure disabled_test;

end;
/

create or replace package body test_demo_package is

  procedure success_test is
  begin
    ut.expect(to_clob('a')).to_equal(to_clob('a'));
  end;

  procedure failing_test is
  begin
    ut.expect(to_blob('a')).to_equal(to_blob('b'));
  end;

  procedure erroring_test is
  begin
    ut.expect(1).to_equal(1/0);
  end;

  procedure disabled_test is
  begin
    ut.expect(1).to_equal(1/0);
  end;

end;
/

