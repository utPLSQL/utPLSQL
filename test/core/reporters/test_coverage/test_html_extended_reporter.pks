create or replace package test_html_extended_reporter is

  --%suite(ut_html_extended_reporter)
  --%suitepath(utplsql.core.reporters.test_extended_coverage)

  --%test(reports on a project file mapped to database object in extended profiler coverage)
  procedure report_on_file;

end test_html_extended_reporter;
/
