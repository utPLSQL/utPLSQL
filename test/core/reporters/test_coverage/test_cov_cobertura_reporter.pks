create or replace package test_cov_cobertura_reporter is

  --%suite(ut_cov_cobertura_reporter)
  --%suitepath(utplsql.core.reporters.test_coverage)

  --%test(reports on a project file mapped to database object)
  procedure report_on_file;

end test_cov_cobertura_reporter;
/
