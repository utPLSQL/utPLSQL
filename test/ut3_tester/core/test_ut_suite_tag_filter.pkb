create or replace package body test_ut_suite_tag_filter is

  procedure test_conversion_to_rpn is
    l_postfix ut3_develop.ut_varchar2_list;
    l_postfix_string varchar2(4000);
    l_input_token ut3_develop.ut_varchar2_list;
  begin
    l_input_token := ut3_develop.ut_suite_tag_filter.tokenize_tags_string('A');
    l_postfix := ut3_develop.ut_suite_tag_filter.shunt_logical_expression(l_input_token);
    l_postfix_string := ut3_develop.ut_utils.table_to_clob(l_postfix,'');
    ut.expect(l_postfix_string).to_equal('A');

    l_input_token := ut3_develop.ut_suite_tag_filter.tokenize_tags_string('A|B');
    l_postfix := ut3_develop.ut_suite_tag_filter.shunt_logical_expression(l_input_token);
    l_postfix_string := ut3_develop.ut_utils.table_to_clob(l_postfix,'');
    ut.expect(l_postfix_string).to_equal('AB|');

    l_input_token := ut3_develop.ut_suite_tag_filter.tokenize_tags_string('(a|b)|c&d');
    l_postfix := ut3_develop.ut_suite_tag_filter.shunt_logical_expression(l_input_token);
    l_postfix_string := ut3_develop.ut_utils.table_to_clob(l_postfix,'');
    ut.expect(l_postfix_string).to_equal('ab|cd&|');     

    l_input_token := ut3_develop.ut_suite_tag_filter.tokenize_tags_string('!a|b');
    l_postfix := ut3_develop.ut_suite_tag_filter.shunt_logical_expression(l_input_token);
    l_postfix_string := ut3_develop.ut_utils.table_to_clob(l_postfix,'');
    ut.expect(l_postfix_string).to_equal('a!b|');         
  end;

  procedure test_conversion_opr_by_opr is
    l_postfix ut3_develop.ut_varchar2_list;
    l_input_token ut3_develop.ut_varchar2_list;
  begin
    l_input_token := ut3_develop.ut_varchar2_list('A','B');
    l_postfix := ut3_develop.ut_suite_tag_filter.shunt_logical_expression(l_input_token);
    ut.fail('Expected exception but nothing was raised');
  end;

  procedure test_conversion_oprd_by_opd is
    l_postfix ut3_develop.ut_varchar2_list;
    l_input_token ut3_develop.ut_varchar2_list;
  begin
    l_input_token := ut3_develop.ut_varchar2_list('|','|');
    l_postfix := ut3_develop.ut_suite_tag_filter.shunt_logical_expression(l_input_token);
    ut.fail('Expected exception but nothing was raised');
  end;

  procedure test_conversion_lb_by_oper is
    l_postfix ut3_develop.ut_varchar2_list;
    l_input_token ut3_develop.ut_varchar2_list;
  begin
    l_input_token := ut3_develop.ut_varchar2_list('(','A','|','B',')','(');
    l_postfix := ut3_develop.ut_suite_tag_filter.shunt_logical_expression(l_input_token);
    ut.fail('Expected exception but nothing was raised');
  end;

  procedure test_conversion_rb_by_oprd is
    l_postfix ut3_develop.ut_varchar2_list;
    l_input_token ut3_develop.ut_varchar2_list;
  begin
    l_input_token := ut3_develop.ut_varchar2_list(')','A');
    l_postfix := ut3_develop.ut_suite_tag_filter.shunt_logical_expression(l_input_token);
    ut.fail('Expected exception but nothing was raised');
  end;

  procedure conv_from_rpn_to_sql_filter is
    l_postfix_rpn ut3_develop.ut_varchar2_list;
    l_infix_string varchar2(4000);
  begin
    l_postfix_rpn := ut3_develop.ut_varchar2_list('A');
    l_infix_string := ut3_develop.ut_suite_tag_filter.conv_postfix_to_infix_sql(l_postfix_rpn);
    ut.expect(l_infix_string).to_equal(q'['A' member of tags]');
    
    l_postfix_rpn := ut3_develop.ut_varchar2_list('A','B','|');
    l_infix_string := ut3_develop.ut_suite_tag_filter.conv_postfix_to_infix_sql(l_postfix_rpn);
    ut.expect(l_infix_string).to_equal(q'[('A' member of tags|'B' member of tags)]');

    l_postfix_rpn := ut3_develop.ut_varchar2_list('a','b','!','|');
    l_infix_string := ut3_develop.ut_suite_tag_filter.conv_postfix_to_infix_sql(l_postfix_rpn);
    ut.expect(l_infix_string).to_equal(q'[('a' member of tags|!('b' member of tags))]');  
  end;

end test_ut_suite_tag_filter;
/
