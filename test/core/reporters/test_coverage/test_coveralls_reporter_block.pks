create or replace package test_coveralls_reporter_block is

  --%suite(ut_coveralls_reporter_block)
  --%suitepath(utplsql.core.reporters.test_block_coverage)

  --%test(reports on a project file mapped to database object in block coverage)
  procedure report_on_file;

end;
/
