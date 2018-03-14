create or replace package test_coverage_sonar_rprt_blk is

  --%suite(ut_test_coverage_sonar_rprt_blk)
  --%suitepath(utplsql.core.reporters.test_block_coverage)

  --%test(reports on a project file mapped to database object in block coverage)
  procedure report_on_file;

end;
/
