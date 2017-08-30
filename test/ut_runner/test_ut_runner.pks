create or replace package test_ut_runner is

  --%suite(ut_runner)
  --%suitepath(utplsql.core)

  --%test(version_compatibility_check compares major, minor and bugfix number)
  procedure version_comp_check_compare;

  --%test(version_compatibility_check ignores build number)
  procedure version_comp_check_ignore;

  --%test(version_compatibility_check compares short version to a full version)
  procedure version_comp_check_short;

  --%test(version_compatibility_check raises exception when invalid version passed)
  procedure version_comp_check_exception;

  --%test(run resets cache of package body after every run)
  procedure run_reset_package_body_cache;

end;
/
