create or replace package test_coverage is

  --%suite
  --%suitepath(utplsql.test_user.reporters)

  function block_coverage_available return boolean;

  --%beforeall(ut3_tester_helper.coverage_helper.create_test_results_table)
  --%beforeall(ut3_tester_helper.coverage_helper.create_dummy_coverage)


  --%afterall(ut3_tester_helper.coverage_helper.drop_dummy_coverage)
  --%afterall(ut3_tester_helper.coverage_helper.drop_test_results_table)

end;
/
