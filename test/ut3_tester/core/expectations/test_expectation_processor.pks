create or replace package test_expectation_processor is

  --%suite(expectation_processor)
  --%suitepath(utplsql.framework_tester.core.expectations)

  --%context(who_called_expectation)

  --%test(parses stack trace and returns object and line that called expectation)
  procedure who_called_expectation;

  --%test(parses stack trace containing 0x and returns object and line that called expectation)
  procedure who_called_expectation_0x;

  --%endcontext

end;
/
