create or replace package body test_ut_coverage_gate is

  procedure pct_full_and_partial is
    l_data ut3_develop.ut_coverage.t_coverage;
  begin
    l_data.covered_lines := 80;
    l_data.uncovered_lines := 20;
    ut.expect(ut3_develop.ut_coverage_gate.coverage_pct(l_data)).to_equal(80);

    l_data.covered_lines := 50;
    l_data.uncovered_lines := 50;
    ut.expect(ut3_develop.ut_coverage_gate.coverage_pct(l_data)).to_equal(50);
  end;

  procedure pct_zero_denominator is
    l_data ut3_develop.ut_coverage.t_coverage;
  begin
    -- default record: covered_lines = 0, uncovered_lines = 0
    ut.expect(ut3_develop.ut_coverage_gate.coverage_pct(l_data)).to_equal(0);
  end;

  procedure pct_rounding is
    l_data ut3_develop.ut_coverage.t_coverage;
  begin
    l_data.covered_lines := 1;
    l_data.uncovered_lines := 2;
    ut.expect(ut3_develop.ut_coverage_gate.coverage_pct(l_data)).to_equal(33.33);
  end;

  procedure assert_pass_equal_and_above is
    l_data ut3_develop.ut_coverage.t_coverage;
  begin
    l_data.covered_lines := 80;
    l_data.uncovered_lines := 20;
    -- equal to threshold and above: no exception expected
    ut3_develop.ut_coverage_gate.assert_coverage(l_data, 80);
    ut3_develop.ut_coverage_gate.assert_coverage(l_data, 79);
  end;

  procedure assert_noop_null_and_negative is
    l_data ut3_develop.ut_coverage.t_coverage;
  begin
    l_data.covered_lines := 10;
    l_data.uncovered_lines := 90;
    -- null or negative threshold disables the gate: no exception expected
    ut3_develop.ut_coverage_gate.assert_coverage(l_data, null);
    ut3_develop.ut_coverage_gate.assert_coverage(l_data, -1);
  end;

  procedure assert_fails_below_threshold is
    l_data ut3_develop.ut_coverage.t_coverage;
    l_code binary_integer;
    l_msg  varchar2(4000);
  begin
    l_data.covered_lines := 50;
    l_data.uncovered_lines := 50;
    begin
      ut3_develop.ut_coverage_gate.assert_coverage(l_data, 80);
      ut.fail('Expected ex_coverage_below_threshold but nothing was raised');
    exception
      when ut3_develop.ut_coverage_gate.ex_coverage_below_threshold then
        l_code := sqlcode;
        l_msg  := sqlerrm;
    end;
    ut.expect(l_code).to_equal(-20218);
    ut.expect(l_msg).to_be_like('%50.00%below%80.00%');
  end;

  procedure assert_fails_with_custom_message is
    l_data ut3_develop.ut_coverage.t_coverage;
    l_msg  varchar2(4000);
  begin
    l_data.covered_lines := 1;
    l_data.uncovered_lines := 3;
    begin
      ut3_develop.ut_coverage_gate.assert_coverage(l_data, 80, 'Nightly build');
      ut.fail('Expected ex_coverage_below_threshold but nothing was raised');
    exception
      when ut3_develop.ut_coverage_gate.ex_coverage_below_threshold then
        l_msg := sqlerrm;
    end;
    ut.expect(l_msg).to_be_like('%Nightly build:%25.00%below%80.00%');
  end;

end;
/
