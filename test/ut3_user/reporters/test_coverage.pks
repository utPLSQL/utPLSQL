create or replace package test_coverage is

  --%suite
  --%suitepath(utplsql.test_user.reporters)

  --%beforeall
  procedure create_dummy_coverage_pkg;
  --%beforeall
  procedure setup_dummy_coverage;


  --%afterall(ut3_tester_helper.coverage_helper.drop_dummy_coverage_pkg)

  --%afterall(ut3_tester_helper.coverage_helper.cleanup_dummy_coverage)

end;
/
