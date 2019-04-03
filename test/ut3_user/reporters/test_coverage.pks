create or replace package test_coverage is

  --%suite
  --%suitepath(utplsql.test_user.reporters)

  g_run_id integer;

  --%beforeall
  procedure create_dummy_coverage_pkg;
  --%beforeall
  procedure setup_dummy_coverage;


  --%afterall
  procedure drop_dummy_coverage_pkg;
  --%afterall
  procedure cleanup_dummy_coverage;

end;
/
