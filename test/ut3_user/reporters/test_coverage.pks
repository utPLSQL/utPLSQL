create or replace package test_coverage is

  --%suite
  --%suitepath(utplsql.test_user.reporters)

  $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
    gc_block_coverage_enabled constant boolean := true;
  $else
    gc_block_coverage_enabled constant boolean := false;
  $end

  --%beforeall(ut3_tester_helper.coverage_helper.create_test_results_table)
  --%beforeall(ut3_tester_helper.coverage_helper.create_dummy_coverage)


  --%afterall(ut3_tester_helper.coverage_helper.drop_dummy_coverage)
  --%afterall(ut3_tester_helper.coverage_helper.drop_test_results_table)

end;
/
