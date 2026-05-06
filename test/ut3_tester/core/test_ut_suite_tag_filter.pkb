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

  procedure conversion_throws_when_lb_rb is
    l_postfix ut3_develop.ut_varchar2_list;
    l_input_token ut3_develop.ut_varchar2_list;
  begin
    l_input_token := ut3_develop.ut_varchar2_list('(',')');
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

  procedure filtering_is_correctly_applied_to_all_items is
      l_input_data ut3_develop.ut_suite_cache_rows;
      l_expected   sys_refcursor;
      l_actual     sys_refcursor;
  begin
      l_input_data := ut3_develop.ut_suite_cache_rows(
          ut3_develop.ut_suite_cache_row(
            1, 'UT_SUITE', 'some.path.test_tags', 'TEST_USER', 'TEST_TAGS', 'TEST_TAGS', 3, timestamp '2026-05-06 10:23:38.461299', NULL, NULL, 0, NULL,  null,  null,  null, null, null, null, null, null,
            ut3_develop.ut_varchar2_rows('slow'), null),
          ut3_develop.ut_suite_cache_row(
            2, 'UT_SUITE_CONTEXT', 'some.path.test_tags.nested_context_#1', 'TEST_USER', 'TEST_TAGS', 'NESTED_CONTEXT_#1', 9, timestamp '2026-05-06 10:23:38.461299', 'tags_are_applied_in_contexts', NULL, 0, NULL, null,  null, null, null, null, null, null, null,
            ut3_develop.ut_varchar2_rows('context_tag'), null),
          ut3_develop.ut_suite_cache_row(
            3, 'UT_TEST', 'some.path.test_tags.nested_context_#1.create_new_mapping', 'TEST_USER', 'TEST_TAGS', 'CREATE_NEW_MAPPING', 11, timestamp '2026-05-06 10:23:38.461299', NULL, NULL, 0, NULL, null,  null, null, null, null, null, null, null,
            ut3_develop.ut_varchar2_rows('test_tag'), ut3_develop.ut_executable_test('UT_EXECUTABLE_TEST', 'test', 'TEST_USER', 'test_tags', 'create_new_mapping', NULL, NULL, NULL, NULL))
      );

      ut.expect(ut3_develop.ut_suite_tag_filter.apply( l_input_data, 'slow').count).to_equal(3 );

      open l_expected for select * from table( l_input_data );
      open l_actual for select * from table( ut3_develop.ut_suite_tag_filter.apply( l_input_data, 'slow') );
      ut.expect(l_actual).to_equal(l_expected).join_by('ID');

      ut.expect( ut3_develop.ut_suite_tag_filter.apply(l_input_data, '!slow').count ).to_equal(0);
      ut.expect( ut3_develop.ut_suite_tag_filter.apply(l_input_data, 'bad').count ).to_equal(0);
      ut.expect( ut3_develop.ut_suite_tag_filter.apply(l_input_data, '!bad').count ).to_equal(3);
      ut.expect( ut3_develop.ut_suite_tag_filter.apply(l_input_data, '!context_tag').count ).to_equal(0);
      ut.expect( ut3_develop.ut_suite_tag_filter.apply(l_input_data, 'context_tag').count ).to_equal(3);
      ut.expect( ut3_develop.ut_suite_tag_filter.apply(l_input_data, '!test_tag').count ).to_equal(0);
      ut.expect( ut3_develop.ut_suite_tag_filter.apply(l_input_data, 'test_tag').count ).to_equal(3);
  end;

end test_ut_suite_tag_filter;
/
