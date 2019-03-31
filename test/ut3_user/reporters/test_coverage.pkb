create or replace package body test_coverage is

  function get_mock_run_id return integer is
    v_result integer;
  begin
    return ut3_tester_helper.coverage_helper.get_mock_run_id();
  end;

  procedure create_dummy_coverage_package is
  begin
    ut3_tester_helper.coverage_helper.create_dummy_coverage_package();
  end;

  procedure create_dummy_coverage_test is
  begin
    ut3_tester_helper.coverage_helper.create_dummy_coverage_test();
  end;

  procedure mock_coverage_data(a_run_id integer) is
  begin
    ut3_tester_helper.coverage_helper.mock_coverage_data(a_run_id,user);
  end;

  procedure create_dummy_coverage_pkg is
  begin
    create_dummy_coverage_package();
    create_dummy_coverage_test();
    ut3_tester_helper.coverage_helper.grant_exec_on_cov();
  end;

  procedure setup_dummy_coverage is
    pragma autonomous_transaction;
  begin
    g_run_id := get_mock_run_id();
    ut3.ut_coverage.mock_coverage_id(g_run_id, ut3.ut_coverage.gc_proftab_coverage);
    mock_coverage_data(g_run_id);
    commit;
  end;

  procedure drop_dummy_coverage_pkg is
  begin
    ut3_tester_helper.coverage_helper.drop_dummy_coverage_pkg();
  end;

  procedure cleanup_dummy_coverage is
  begin
    ut3_tester_helper.coverage_helper.cleanup_dummy_coverage(g_run_id);
  end;

end;
/
