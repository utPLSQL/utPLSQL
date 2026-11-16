create or replace package test_ut_metadata
is
  --%suite(ut_metadata)
  --%suitepath(utplsql.ut3_tester.core)

  --%test(source line is over varchar2 limit)
  procedure test_over_varchar2_limit;

  --%beforeall
  procedure create_test_package;
  --%afterall
  procedure drop_test_package;
end;
/