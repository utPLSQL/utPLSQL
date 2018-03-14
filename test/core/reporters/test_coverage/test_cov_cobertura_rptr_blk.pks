create or replace package test_cov_cobertura_rptr_blk is

  --%suite(ut_test_cov_cobertura_rptr_blk)
  --%suitepath(utplsql.core.reporters.test_block_coverage)

  --%test(reports on a project file mapped to database object in block coverage)
  procedure report_on_file;

end test_cov_cobertura_rptr_blk;
/
