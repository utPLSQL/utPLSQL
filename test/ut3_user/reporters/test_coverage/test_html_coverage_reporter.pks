create or replace package test_html_coverage_reporter is

  --%suite(ut_html_extended_reporter)
  --%suitepath(utplsql.test_user.reporters.test_coverage.test_extended_coverage)

  --%test(reports on a project file mapped to database object in extended profiler coverage)
  procedure report_on_file;

  procedure setup_long_lines;
  procedure cleanup_long_lines;

  --%test(reports on lines exceeding 4000 chars after conversion to XML)
  --%beforetest(setup_long_lines)
  --%aftertest(cleanup_long_lines)
  procedure report_long_lines;

end test_html_coverage_reporter;
/
