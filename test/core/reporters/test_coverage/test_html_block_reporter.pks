create or replace package test_html_block_reporter is

  --%suite(ut_html_block_reporter)
  --%suitepath(utplsql.core.reporters.test_block_coverage)

  --%test(reports on a project file mapped to database object in block coverage)
  procedure report_on_file;

end test_html_block_reporter;
/
