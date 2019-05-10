create or replace package test_cov_cobertura_reporter is

  --%suite(ut_cov_cobertura_reporter)
  --%suitepath(utplsql.test_user.reporters.test_coverage)

  --%test(reports on a project file mapped to database object)
  procedure report_on_file;

  --%test(reports zero coverage on each line of non-executed database object - Issue #917)
  procedure report_zero_coverage;

end test_cov_cobertura_reporter;
/
