create or replace package ut_fail_suite as

  g_fail_setup boolean := false;

  g_fail_teardown boolean := false;

  procedure suite_setup;

  procedure test;

  procedure suite_teardown;

end;
/
create or replace package body ut_fail_suite as

  procedure suite_setup is
  begin
    if g_fail_setup then
      raise_application_error(-20998, 'Setup failed');
    end if;
  end;

  procedure test is
  begin
    null;
  end;

  procedure suite_teardown is
  begin
    if g_fail_teardown then
      raise_application_error(-20999, 'Teardown failed');
    end if;
  end;

end;
/
