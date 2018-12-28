create or replace package test_realtime_reporter as

  --%suite(ut_realtime_reporter)
  --%suitepath(utplsql.core.reporters)

  --%beforeall
  procedure create_test_suites_and_run;
  
  --%test(Check XML report structure)
  procedure xml_report_structure;
  
  --%test(Check total number of tests)
  procedure total_number_of_tests;
  
  --%test(Check escaped characters in test suite description)
  procedure escaped_characters;
  
  --%test(Check number of startTestEvent nodes)
  procedure number_of_starttestevent_nodes;
  
  --%test(Check testNumber and totalNumberOfTests in endTestEvent nodes)
  procedure endtestevent_nodes;

  --%test(Check expectation message for a failed test)
  procedure single_failed_message;

  --%test(Check existence of multiple expectation messages for a failed test)
  procedure multiple_failed_messages;
  
  --%test(Check for serveroutput of test)
  procedure serveroutput_of_test;

  --%test(Check for serveroutput of testsuite)
  procedure serveroutput_of_testsuite;
  
  --%test(Check for error stack of test)
  procedure error_stack_of_test;

  --%test(Check for error stack of testsuite)
  procedure error_stack_of_testsuite;
  
  --%test(Check description of reporter)
  procedure get_description;

  --%afterall
  procedure remove_test_suites;

end test_realtime_reporter;
/
