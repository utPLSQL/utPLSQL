create or replace package test_coverage is

  --%suite
  --%suitepath(utplsql.core.reporters)

  g_run_id integer;

  --%beforeall
  procedure create_dummy_coverage_pkg;
  --%beforeall
  procedure setup_dummy_coverage;


  --%afterall
  procedure drop_dummy_coverage_pkg;
  --%afterall
  procedure cleanup_dummy_coverage;


  --%test(Coverage is gathered for specified object - default coverage type)
  procedure coverage_for_object;

  --%test(Coverage is gathered for specified schema - default coverage type)
  procedure coverage_for_object_no_owner;

  --%test(Coverage is gathered for specified schema)
  procedure coverage_for_schema;

  --%test(Coverage is gathered for specified file - default coverage type)
  procedure coverage_for_file;
  
  --%test(Coverage data is not cached between runs - issue #562 )
  --%aftertest(create_dummy_coverage_pkg)
  --%aftertest(setup_dummy_coverage)
  procedure coverage_tmp_data_refresh;

end;
/
