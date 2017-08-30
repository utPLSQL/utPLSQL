create or replace package body core is

  procedure enable_develop_coverage is
  begin
    ut3.ut_coverage.coverage_start_develop();
  end;

end;
/
