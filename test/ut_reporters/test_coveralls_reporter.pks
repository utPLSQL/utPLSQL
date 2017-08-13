create or replace package test_coveralls_reporter is

  --%suite(ut_coveralls_reporter)
  --%suitepath(utplsql.core.test_coverage.reporters)

  --%test(reports on a project file mapped to database object)
  procedure report_on_file;

end;
/
