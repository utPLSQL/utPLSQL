create or replace package test_coverage_cob_reporter is

  --%suite(ut_coverage_cob_reporter)
  --%suitepath(utplsql.core.reporters.test_coverage)

  --%test(reports on a project file mapped to database object)
  procedure report_on_file;

end;
/
