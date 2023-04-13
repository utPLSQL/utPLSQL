create or replace package test_ut_suite_tag_filter is

  --%suite(ut_suite_tag_filter)
  --%suitepath(utplsql.ut3_tester.core)

  --%test( Test conversion of expression into Reverse Polish Notation)
  procedure test_conversion_to_rpn;

  --%test( Test conversion of expression from Reverse Polish Notation into custom where filter for SQL)
  procedure conv_from_rpn_to_sql_filter;  

end test_ut_suite_tag_filter;
/
