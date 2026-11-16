create or replace package test_ut_metadata is
  --%suite(ut_metadata)
  --%suitepath(utplsql.ut3_tester.core)

  --%test(source line over 4000 limit is trimmed to first 4000)
  procedure test_over_varchar2_limit_trim_first_4000;

  --%beforeall
  procedure create_test_package;
  --%afterall
  procedure drop_test_package;
end;
/