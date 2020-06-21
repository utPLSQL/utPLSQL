create or replace package test_coverage_standalone authid current_user is

  --%suite
  --%suitepath(utplsql.test_user.reporters.test_coverage)

  --%test(Coverage can be invoked standalone in multiple sessions and a combined report can be produced at the end)
  procedure coverage_without_ut_run;

  --%test(Coverage can be invoked standalone in multiple sessions and a combined report can be produced at the end as cursor)
  procedure coverage_cursor_without_ut_run;
end;
/
