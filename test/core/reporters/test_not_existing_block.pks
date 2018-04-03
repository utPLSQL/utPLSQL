create or replace package test_coverage is

  --%suite
  --%suitepath(utplsql.core.reporters)

  --%beforeall
  procedure setup_dummy_coverage;

  --%afterall
  procedure cleanup_dummy_coverage;


  --%test(Coverage is requested for invalid type of coverage)
  --%throws(-20215)
  procedure invalid_coverage_type;

end;
/
