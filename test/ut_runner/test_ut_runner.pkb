create or replace package body test_ut_runner is

  procedure version_comp_check_compare is
  begin
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v3.0.0.0') ).to_be_true;
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v3.0.123.0') ).to_be_true;
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v3.123.0.0') ).to_be_true;
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v3.13.31.0') ).to_be_true;
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.1.0','v3.0.0.0') ).to_be_false;
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.1.0.0','v3.0.0.0') ).to_be_false;
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v2.0.0.0') ).to_be_false;
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v4.0.0.0') ).to_be_false;
  end;
  procedure version_comp_check_ignore is
  begin
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.123','v3.0.0.0') ).to_be_true;
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v3.0.0.123') ).to_be_true;
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0','v3.0.0.0') ).to_be_true;
  end;

end;
/
