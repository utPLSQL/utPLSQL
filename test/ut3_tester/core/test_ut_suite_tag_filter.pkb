create or replace package body test_ut_suite_tag_filter is

  procedure test_conversion_to_rpn is
    l_postfix ut3_develop.ut_varchar2_list;
    l_postfix_string varchar2(4000);
  begin
    l_postfix := ut3_develop.ut_suite_tag_filter.shunt_logical_expression('A');
    l_postfix_string := ut3_develop.ut_utils.table_to_clob(l_postfix,'');
    ut.expect(l_postfix_string).to_equal('A');

    l_postfix := ut3_develop.ut_suite_tag_filter.shunt_logical_expression('A|B');
    l_postfix_string := ut3_develop.ut_utils.table_to_clob(l_postfix,'');
    ut.expect(l_postfix_string).to_equal('AB|');

    l_postfix := ut3_develop.ut_suite_tag_filter.shunt_logical_expression('(a|b)|c&d');
    l_postfix_string := ut3_develop.ut_utils.table_to_clob(l_postfix,'');
    ut.expect(l_postfix_string).to_equal('ab|cd&|');     

    l_postfix := ut3_develop.ut_suite_tag_filter.shunt_logical_expression('!a|b');
    l_postfix_string := ut3_develop.ut_utils.table_to_clob(l_postfix,'');
    ut.expect(l_postfix_string).to_equal('a!b|');         
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
