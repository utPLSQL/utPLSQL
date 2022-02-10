create or replace package test_annot_disabled_reason
is
  --%suite(annotations - disabled)
  --%suitepath(utplsql.ut3_tester.core.annotations)

  --%beforeall
  procedure compile_dummy_packages;
  
  --%afterall
  procedure drop_dummy_packages;

  --%test(Disable all tests under the suite displaying suite level reason)
  procedure test_disable_on_suite_level;

  --%test(Disable all tests under one of two contexts displaying context level reason)
  procedure test_dis_on_1st_ctx_level;

  --%test(Disable a single tests from each of the contexts displaying test level reason)
  procedure test_disable_tests_level;
  
  --%test(Disable tests with reason using special characters and long reason)
  procedure test_long_text_spec_chr;

  --%test(Disable tests on suite , context and test level and display suite level reason)
  procedure test_disable_suite_ctx_tst;

  --%test(Disable tests on context and test level and display context level reason)
  procedure test_disable_ctx_tst;

end;
/
