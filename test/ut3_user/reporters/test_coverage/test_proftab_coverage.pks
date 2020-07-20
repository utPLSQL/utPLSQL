create or replace package test_proftab_coverage is

  --%suite
  --%suitepath(utplsql.test_user.reporters.test_coverage)

  --%test(Coverage is gathered for specified object - default coverage type)
  procedure coverage_for_object;

  --%test(Coverage is gathered for specified schema - default coverage type)
  procedure coverage_for_object_no_owner;

  --%test(Coverage is gathered for specified schema)
  procedure coverage_for_schema;

  --%test(Coverage is gathered for specified file - default coverage type)
  procedure coverage_for_file;

  --%beforetest(ut3_tester_helper.coverage_helper.create_dup_object_name)
  --%aftertest(ut3_tester_helper.coverage_helper.drop_dup_object_name)
  --%test(Coverage on duplicate object name)
  procedure dup_object_name_coverage;
  
  --%test(Coverage data is not cached between runs - issue #562 )
  --%aftertest(ut3_tester_helper.coverage_helper.drop_dummy_coverage_1)
  --%aftertest(ut3_tester_helper.coverage_helper.create_dummy_coverage)
  procedure coverage_tmp_data_refresh;

  --%test(reports zero coverage on each line of non-executed database object - Issue #917)
  procedure report_zero_coverage;

end;
/
