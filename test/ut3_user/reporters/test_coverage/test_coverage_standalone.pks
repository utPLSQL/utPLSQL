create or replace package test_coverage_standalone authid current_user is

  --%suite
  --%suitepath(utplsql.test_user.reporters)

  --%beforeall(ut3_tester_helper.coverage_helper.create_coverage_pkg)
  --%afterall(ut3_tester_helper.coverage_helper.drop_coverage_pkg)

  --%test(Coverage can be invoked standalone in multiple sessions and a combined report can be produced at the end)
  procedure coverage_without_ut_run;

end;
/
