create or replace package test_ut_metadata is
  --%suite(ut_metadata)
  --%suitepath(utplsql.ut3_tester.core)

  --%test(source line over 4000 limit is trimmed to first 4000 [linebreeak lf])
  --%beforetest(create_test_package_lf)
  procedure test_over_varchar2_limit_trim_first_4000_lf;

  --%test(source line over 4000 limit is trimmed to first 4000 [linebreeak:crlf])
  --%beforetest(create_test_package_crlf)
  procedure test_over_varchar2_limit_trim_first_4000_crlf;

  --%disabled(PLS-00103 occurs when execute immediate CR package)
  --%test(source line over 4000 limit is trimmed to first 4000 [linebreeak cr])
  --%beforetest(create_test_package_cr)
  procedure test_over_varchar2_limit_trim_first_4000_cr;

  --%beforeall
  procedure create_table;
  --%afterall
  procedure drop_table;
  --%beforeeach
  procedure clear_cache;
  --%aftereach
  procedure drop_test_package;

  procedure create_test_package_lf;

  procedure create_test_package_crlf;

  procedure create_test_package_cr;

end;
/