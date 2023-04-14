create or replace package test_ut_suite_tag_filter is

  --%suite(ut_suite_tag_filter)
  --%suitepath(utplsql.ut3_tester.core)

  --%context( Conversion to Reverse Polish Notation)

  --%test( Test conversion of expression into Reverse Polish Notation)
  procedure test_conversion_to_rpn;

  --%test( Operator is followed by operator)
  --%throws(ut3_develop.ut_utils.gc_invalid_tag_expression)
  procedure test_conversion_opr_by_opr;  

  --%test( Operand is followed by operand)
  --%throws(ut3_develop.ut_utils.gc_invalid_tag_expression)
  procedure test_conversion_oprd_by_opd;

  --%test( Left Bracket is followed by operator)
  --%throws(ut3_develop.ut_utils.gc_invalid_tag_expression)
  procedure test_conversion_lb_by_oper;

  --%test( Right Bracket is followed by operand)
  --%throws(ut3_develop.ut_utils.gc_invalid_tag_expression)
  procedure test_conversion_rb_by_oprd;

  --%endcontext

  --%test( Test conversion of expression from Reverse Polish Notation into custom where filter for SQL)
  procedure conv_from_rpn_to_sql_filter;  

end test_ut_suite_tag_filter;
/
