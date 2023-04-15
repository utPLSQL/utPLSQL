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

  procedure conv_from_tag_to_sql_filter is
    l_sql_filter varchar2(4000);
  begin
    l_sql_filter := ut3_develop.ut_suite_tag_filter.create_where_filter('test1');
    ut.expect(l_sql_filter).to_equal(q'['test1' member of tags]');
    
    l_sql_filter := ut3_develop.ut_suite_tag_filter.create_where_filter('test1|test2');
    ut.expect(l_sql_filter).to_equal(q'[('test1' member of tags or 'test2' member of tags)]');

    l_sql_filter := ut3_develop.ut_suite_tag_filter.create_where_filter('test1|!test2');
    ut.expect(l_sql_filter).to_equal(q'[('test1' member of tags or not('test2' member of tags))]');  

    l_sql_filter := ut3_develop.ut_suite_tag_filter.create_where_filter('test1&!test2');
    ut.expect(l_sql_filter).to_equal(q'[('test1' member of tags and not('test2' member of tags))]');  
  end;

end test_ut_suite_tag_filter;
/
