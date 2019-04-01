create or replace package test_html_proftab_reporter is

  --%suite(ut_html_proftab_reporter)
  --%suitepath(utplsql.test_user.reporters.test_coverage.test_proftab_coverage)

  --%test(reports on a project file mapped to database object in profiler coverage)
  procedure report_on_file;

end test_html_proftab_reporter;
/
