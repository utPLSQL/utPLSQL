create or replace package body test_coverage is

  procedure create_dummy_coverage_pkg is
  begin
    ut3_tester_helper.coverage_helper.create_dummy_coverage_package();
    ut3_tester_helper.coverage_helper.create_dummy_coverage_test();
    ut3_tester_helper.coverage_helper.grant_exec_on_cov();
  end;

  procedure setup_dummy_coverage is
    pragma autonomous_transaction;
  begin
    ut3_tester_helper.coverage_helper.setup_mock_coverage_id();
    ut3_tester_helper.coverage_helper.mock_coverage_data(user);
    commit;
  end;

end;
/
