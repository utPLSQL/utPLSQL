create or replace package test_ut_runner is

  --%suite(ut_runner)
  --%suitepath(utplsql.core)

  --%test(version_compatibility_check compares major minor bigfix number)
  procedure version_comp_check_compare;

  --%test(version_compatibility_check ignores build number)
  procedure version_comp_check_ignore;

end;
/
