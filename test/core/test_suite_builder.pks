create or replace package test_suite_builder is
  --%suite(suite_builder)
  --%suitepath(utplsql.core)

  --%test(Sets suite name from package name and leaves description empty)
  procedure no_suite_description;
end;
/
