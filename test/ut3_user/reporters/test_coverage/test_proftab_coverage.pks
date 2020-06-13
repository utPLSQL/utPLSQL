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
  
  --%test(Coverage data is not cached between runs - issue #562 )
  --%aftertest(ut3_tester_helper.coverage_helper.create_dummy_coverage)
  --%aftertest(ut3_tester_helper.coverage_helper.drop_dummy_coverage_test_1)
  procedure coverage_tmp_data_refresh;

end;
/
