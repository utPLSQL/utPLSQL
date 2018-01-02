create or replace package body ut_example_tests
as

  procedure set_g_number_0 as
  begin
    g_number := 0;
  end;

  procedure add_1_to_g_number as
  begin
    g_number := g_number + 1;
  end;

  procedure failing_procedure as
  begin
    g_number := 1 / 0;
  end;

end;
/
