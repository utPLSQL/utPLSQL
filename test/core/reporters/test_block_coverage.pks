create or replace package test_block_coverage is

  --%suite
  --%suitepath(utplsql.core.reporters)

  --%beforeall
  procedure setup_dummy_coverage;

  --%afterall
  procedure cleanup_dummy_coverage;

  --%test(Coverage is gathered for specified object - block coverage type)
  procedure coverage_for_object;

  --%test(Coverage is gathered for specified schema - block coverage type)
  procedure coverage_for_schema;

  --%test(Coverage is gathered for specified file - block coverage type)
  procedure coverage_for_file;
  
end;
/
