create or replace package test_coverage is

  --%suite
  --%suitepath(utplsql.core.reporters)

  --%beforeall
  procedure setup_dummy_coverage;

  --%afterall
  procedure cleanup_dummy_coverage;


  --%test(Coverage is gathered for specified object - default coverage type)
  procedure coverage_for_object;

  --%test(Coverage is gathered for specified schema - default coverage type)
  procedure coverage_for_schema;

  --%test(Coverage is gathered for specified file - default coverage type)
  procedure coverage_for_file;

  --%test(Coverage is gathered for specified object - explicit proftab coverage)
  procedure coverage_for_object_proftab;

  --%test(Coverage is gathered for specified schema - explicit proftab coverag)
  procedure coverage_for_schema_proftab;

  --%test(Coverage is gathered for specified file - explicit proftab coverag)
  procedure coverage_for_file_proftab;  
  
  --%test(Coverage data is not cached between runs - issue #562 )
  --%aftertest(setup_dummy_coverage)
  procedure coverage_tmp_data_refresh;

end;
/
