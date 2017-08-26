create or replace package body test_ut_runner is

  procedure version_comp_check_compare is
  begin
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v3.0.0.0') ).to_equal(1);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v3.0.123.0') ).to_equal(1);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v3.123.0.0') ).to_equal(1);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v3.13.31.0') ).to_equal(1);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.1.0','v3.0.0.0') ).to_equal(0);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.1.0.0','v3.0.0.0') ).to_equal(0);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v2.0.0.0') ).to_equal(0);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v4.0.0.0') ).to_equal(0);
  end;

  procedure version_comp_check_ignore is
  begin
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.123','v3.0.0.0') ).to_equal(1);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v3.0.0.123') ).to_equal(1);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0','v3.0.0.0') ).to_equal(1);
  end;

  procedure version_comp_check_short is
  begin
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0','v3.0.0.0') ).to_equal(1);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0','v3.0.123.0') ).to_equal(1);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3','v3.123.0.0') ).to_equal(1);
  end;

  procedure version_comp_check_exception is
    procedure throws(a_requested varchar2, a_current varchar2) is
      l_compatible integer;
    begin
      l_compatible := ut3.ut_runner.version_compatibility_check(a_requested,a_current);
      ut.fail('Expected exception but nothing was raised');
    exception
      when others then
        ut.expect(sqlcode).to_equal(-20214);
    end;
  begin
    throws('bad_ver','v3.0.0.0');
    throws('v3.0.0.0','bad_ver');
  end;

end;
/
