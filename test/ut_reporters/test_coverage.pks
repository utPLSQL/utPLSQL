create or replace package test_coverage is

  --%suite
  --%suitepath(utplsql.core)

  --%beforeall
  procedure setup_dummy_coverage;

  --%afterall
  procedure cleanup_dummy_coverage;

end;
/
