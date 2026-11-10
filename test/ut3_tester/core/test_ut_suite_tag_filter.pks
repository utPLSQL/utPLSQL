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

  --%test(Conversion raises exception when empty brackets)
  --%throws(ut3_develop.ut_utils.gc_invalid_tag_expression)
  procedure conversion_throws_when_lb_rb;

  --%test(Conversion raises exception when a right bracket has no left bracket)
  --%throws(ut3_develop.ut_utils.gc_invalid_tag_expression)
  procedure conversion_throws_when_unmatched_rb;

  --%endcontext

  --%test( Evaluates or, and and not in tag expressions)
  procedure is_matching_or_and_not;

  --%test( Evaluates tag expressions against a list of tags)
  procedure is_matching_evaluates_tags;

  --%test( Evaluates none and any for items without tags)
  procedure is_matching_without_tags;

  --%test( Evaluates each distinct set of tags once per SQL statement)
  procedure is_matching_is_cached_in_sql;

  --%test( Raises exception for an invalid tag expression)
  --%throws(ut3_develop.ut_utils.gc_invalid_tag_expression)
  procedure is_matching_invalid_expression;

  procedure create_tags_suite;
  procedure drop_tags_suite;

  --%test( Regression for issue #1324 - corect filtering by tags with suitepath and contexts)
  --%beforetest(create_tags_suite)
  --%aftertest(drop_tags_suite)
  procedure filtering_is_correctly_applied_to_all_items;

end test_ut_suite_tag_filter;
/
