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

  --%test(Conversion raises exception for an empty list of tokens)
  --%throws(ut3_develop.ut_utils.gc_invalid_tag_expression)
  procedure conversion_throws_when_empty;

  --%test(Conversion raises exception when the expression ends with an operator)
  --%throws(ut3_develop.ut_utils.gc_invalid_tag_expression)
  procedure conversion_throws_when_trailing_opr;

  --%test(Tokenizing an empty string returns no tokens)
  procedure tokenize_empty_string;

  --%endcontext

  --%test( Evaluates or, and and not in tag expressions)
  procedure is_matching_or_and_not;

  --%test( Evaluates tag expressions against a list of tags)
  procedure is_matching_evaluates_tags;

  --%test( Evaluates none and any for items without tags)
  procedure is_matching_without_tags;

  --%test( Applies operator precedence, brackets and double negation)
  procedure is_matching_operator_precedence;

  --%test( Combines none and any with other tags)
  procedure is_matching_none_and_any_combined;

  --%test( Compares tags and the none and any keywords case sensitively)
  procedure is_matching_is_case_sensitive;

  --%test( Ignores spaces and tabs in the tag expression)
  procedure is_matching_ignores_whitespace;

  --%test( Matches any tags when the tag expression is empty or made of spaces and tabs)
  procedure is_matching_empty_expression;

  --%test( Returns null for an empty tag expression made of spaces and tabs)
  procedure empty_to_null_for_blank_expression;

  --%test( Evaluates a tag containing a quote)
  procedure is_matching_tag_with_quote;

  --%test( Evaluates an expression with many tags)
  procedure is_matching_many_tags;

  --%test( Follows three-valued logic for an empty element in the list of tags)
  procedure is_matching_null_tag_element;

  --%test( Evaluates the current expression after the expression changes or an invalid expression is given)
  procedure is_matching_follows_expression_change;

  --%test( Raises exception for an invalid tag expression)
  --%throws(ut3_develop.ut_utils.gc_invalid_tag_expression)
  procedure is_matching_invalid_expression;

  --%test( Raises exception for an incomplete tag expression)
  procedure is_matching_incomplete_expression;

  procedure create_tags_suite;
  procedure drop_tags_suite;

  --%test( Regression for issue #1324 - corect filtering by tags with suitepath and contexts)
  --%beforetest(create_tags_suite)
  --%aftertest(drop_tags_suite)
  procedure filtering_is_correctly_applied_to_all_items;

end test_ut_suite_tag_filter;
/
