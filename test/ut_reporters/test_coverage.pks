create or replace package test_coverage is

  --%suite
  --%suitepath(utplsql.core.reporters)

  --%beforeall
  procedure setup_dummy_coverage;

  --%afterall
  procedure cleanup_dummy_coverage;

  --%test(Coverage is gathered for specified object)
  procedure coverage_for_object;

  --%test(Coverage is gathered for specified schema)
  procedure coverage_for_schema;

  --%test(Coverage is gathered for specified file)
  procedure coverage_for_file;
end;
/
