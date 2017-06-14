create or replace package body test_reporters_1
as
  procedure diffrentowner_test
  is
    l_result number;
  begin
    ut3$user#.html_coverage_test.run_if_statment(l_result);
    ut.expect(l_result).to_equal(1);
  end;
end;
/
