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

  procedure conversion_throws_when_unmatched_rb is
    l_postfix ut3_develop.ut_varchar2_list;
    l_input_token ut3_develop.ut_varchar2_list;
  begin
    l_input_token := ut3_develop.ut_varchar2_list('(','a',')',')');
    l_postfix := ut3_develop.ut_suite_tag_filter.shunt_logical_expression(l_input_token);
    ut.fail('Expected exception but nothing was raised');
  end;

  procedure conversion_throws_when_empty is
    l_postfix ut3_develop.ut_varchar2_list;
  begin
    l_postfix := ut3_develop.ut_suite_tag_filter.shunt_logical_expression(ut3_develop.ut_varchar2_list());
    ut.fail('Expected exception but nothing was raised');
  end;

  procedure conversion_throws_when_trailing_opr is
    l_postfix ut3_develop.ut_varchar2_list;
  begin
    l_postfix := ut3_develop.ut_suite_tag_filter.shunt_logical_expression(ut3_develop.ut_varchar2_list('a','|'));
    ut.fail('Expected exception but nothing was raised');
  end;

  procedure tokenize_empty_string is
  begin
    ut.expect( ut3_develop.ut_suite_tag_filter.tokenize_tags_string(null).count ).to_equal(0);
  end;

  procedure is_matching_or_and_not is
  begin
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('test1', 'test1') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('test2', 'test1') ).to_equal(0);

    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('test2', 'test1|test2') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('test3', 'test1|test2') ).to_equal(0);

    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('test3', 'test1|!test2') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('test2', 'test1|!test2') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('test1,test2', 'test1|!test2') ).to_equal(1);

    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('test1', 'test1&!test2') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('test1,test2', 'test1&!test2') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('test3', 'test1&!test2') ).to_equal(0);
  end;

  procedure is_matching_evaluates_tags is
    l_tags varchar2(100) := 'db,slow';
  begin
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(l_tags, 'slow') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(l_tags, 'fast') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(l_tags, 'slow&db') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(l_tags, 'slow&!db') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(l_tags, 'fast|db') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(l_tags, '!fast') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(l_tags, '(fast|slow)&!(db&fast)') ).to_equal(1);
    --legacy notation: "," is or, "-" is not
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(l_tags, 'fast,slow') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(l_tags, 'fast,-slow') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(l_tags, 'none') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(l_tags, 'any') ).to_equal(1);
  end;

  procedure is_matching_without_tags is
  begin
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(null, 'none') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(null, 'any') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(null, '!slow') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(null, 'slow') ).to_equal(0);
  end;

  procedure is_matching_operator_precedence is
  begin
    --"&" binds stronger than "|"
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a', 'a|b&c') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('b', 'a|b&c') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('b,c', 'a|b&c') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('c', 'b&c|a') ).to_equal(0);
    --brackets
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a', '(a|b)&c') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a,c', '(a|b)&c') ).to_equal(1);
    --"!" binds stronger than "&"
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('b', '!a&b') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a,b', '!a&b') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a', '!(a&b)') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a,b', '!(a&b)') ).to_equal(0);
    --double negation
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a', '!!a') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('b', '!!a') ).to_equal(0);
  end;

  procedure is_matching_none_and_any_combined is
  begin
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('slow', 'none|slow') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(null, 'none|slow') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('db', 'none|slow') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('slow', '!none') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(null, '!none') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(null, '!any') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('slow', 'any&!slow') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('db', 'any&!slow') ).to_equal(1);
  end;

  procedure is_matching_is_case_sensitive is
  begin
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('Slow', 'slow') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('slow', 'SLOW') ).to_equal(0);
    --upper case keywords are tags, not the none and any keywords
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(null, 'NONE') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('slow', 'ANY') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('ANY', 'ANY') ).to_equal(1);
  end;

  procedure is_matching_ignores_whitespace is
    c_tab constant varchar2(1) := chr(9);
  begin
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('db,slow', ' slow & db ') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('db,slow', ' ( fast | slow ) & ! db ') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('db,slow', c_tab||'slow'||c_tab||'&'||c_tab||'db'||c_tab) ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('db,slow', 'slow'||c_tab||'&'||c_tab||'!'||c_tab||'db') ).to_equal(0);
    --legacy notation
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('db,slow', 'fast, slow') ).to_equal(1);
  end;

  procedure is_matching_empty_expression is
    c_tab constant varchar2(1) := chr(9);
  begin
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('slow', null) ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(null, null) ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('slow', ' ') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(null, '   ') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('slow', c_tab) ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(null, ' '||c_tab||' ') ).to_equal(1);
  end;

  procedure empty_to_null_for_blank_expression is
    c_tab constant varchar2(1) := chr(9);
  begin
    ut.expect( ut3_develop.ut_suite_tag_filter.empty_to_null(null) ).to_be_null();
    ut.expect( ut3_develop.ut_suite_tag_filter.empty_to_null(' ') ).to_be_null();
    ut.expect( ut3_develop.ut_suite_tag_filter.empty_to_null(' '||c_tab||c_tab||' ') ).to_be_null();
    --a non-empty expression is returned unchanged
    ut.expect( ut3_develop.ut_suite_tag_filter.empty_to_null(' slow & db ') ).to_equal(' slow & db ');
  end;

  procedure is_matching_tag_with_quote is
  begin
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(q'[it's]', q'[it's]') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('slow', q'[slow&!it's]') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('slow', q'[it's]') ).to_equal(0);
  end;

  procedure is_matching_many_tags is
    c_tag_prefix constant varchar2(30) := 'a_long_tag_name_for_testing_';
    l_expression varchar2(32767);
  begin
    --80 tags of 31 characters, joined with "|": a condition with "member of" for each tag would be over 4000 characters
    for i in 1 .. 80 loop
      l_expression := l_expression || case when i > 1 then '|' end || c_tag_prefix || lpad(i, 3, '0');
    end loop;
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching(c_tag_prefix||'080', l_expression) ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('slow,'||c_tag_prefix||'001', l_expression) ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('slow', l_expression) ).to_equal(0);
  end;

  procedure is_matching_null_tag_element is
  begin
    --'a,,b' has a null element, so "x member of" it is unknown (null) instead of false when x is not in the list
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a,,b', 'a') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a,,b', 'x') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a,,b', '!x') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a,,b', 'a|!x') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a,,b', 'a&!x') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a,,b', '!a&!x') ).to_equal(0);
  end;

  procedure is_matching_follows_expression_change is
    l_result integer;
  begin
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a', 'a') ).to_equal(1);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a', 'b') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a', 'a') ).to_equal(1);
    begin
      l_result := ut3_develop.ut_suite_tag_filter.is_matching('a', 'a&');
      ut.fail('Expected exception but nothing was raised');
    exception
      when others then
        ut.expect( sqlcode ).to_equal( ut3_develop.ut_utils.gc_invalid_tag_expression );
    end;
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a', 'b') ).to_equal(0);
    ut.expect( ut3_develop.ut_suite_tag_filter.is_matching('a', 'a') ).to_equal(1);
  end;

  procedure is_matching_invalid_expression is
    l_result integer;
  begin
    l_result := ut3_develop.ut_suite_tag_filter.is_matching('slow', 'slow&|db');
  end;

  procedure is_matching_incomplete_expression is
    --legacy notation turns ',' into an empty expression
    l_expressions ut3_develop.ut_varchar2_list := ut3_develop.ut_varchar2_list('slow|', 'slow&!', '!', '(slow', ',');
    l_result      integer;
  begin
    for i in 1 .. l_expressions.count loop
      begin
        l_result := ut3_develop.ut_suite_tag_filter.is_matching('slow', l_expressions(i));
        ut.fail('Expected exception for tag expression "'||l_expressions(i)||'" but nothing was raised');
      exception
        when others then
          ut.expect( sqlcode, 'Tag expression "'||l_expressions(i)||'"' ).to_equal( ut3_develop.ut_utils.gc_invalid_tag_expression );
      end;
    end loop;
  end;

  procedure create_tags_suite is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package test_tags_1324 as
      --%suite
      --%suitepath(some.path)
      --%tags(slow)

      --%context(tags_are_applied_in_contexts)
      --%tags(context_tag)

      --%test
      --%tags(test_tag)
      procedure create_new_mapping;

      --%endcontext
    end;]';
    execute immediate q'[create or replace package body test_tags_1324 as
      procedure create_new_mapping is begin null; end;
    end;]';
  end;

  procedure drop_tags_suite is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package test_tags_1324';
  end;

  procedure filtering_is_correctly_applied_to_all_items is
      l_paths    ut3_develop.ut_path_items;
      l_suites   ut3_develop.ut_suite_items;
      l_items    ut3_develop.ut_suite_cache_rows;
      l_expected sys_refcursor;
      l_actual   sys_refcursor;

      --suite items selected by the tag expression, without the logical suites "some" and "some.path"
      function get_items(a_tags varchar2) return ut3_develop.ut_suite_cache_rows is
        l_rows   ut3_develop.ut_suite_cache_rows;
        l_result ut3_develop.ut_suite_cache_rows;
      begin
        l_rows := ut3_develop.ut_suite_cache_manager.get_suite_rows( l_paths, true, a_tags );
        select value(r) bulk collect into l_result from table(l_rows) r where r.self_type != 'UT_LOGICAL_SUITE';
        return l_result;
      end;
  begin
      --refresh the suite cache of the schema
      l_suites := ut3_develop.ut_suite_manager.configure_execution_by_path(ut3_develop.ut_varchar2_list('ut3_tester.test_tags_1324'));
      l_paths := ut3_develop.ut_suite_cache_manager.get_schema_paths(ut3_develop.ut_varchar2_list('ut3_tester.test_tags_1324'));

      l_items := get_items('slow');
      ut.expect( l_items.count ).to_equal(3);

      open l_expected for
        select 'some.path.test_tags_1324' as path from dual union all
        select 'some.path.test_tags_1324.nested_context_#1' from dual union all
        select 'some.path.test_tags_1324.nested_context_#1.create_new_mapping' from dual;
      open l_actual for select r.path from table( l_items ) r;
      ut.expect(l_actual).to_equal(l_expected).unordered();

      ut.expect( get_items('!slow').count ).to_equal(0);
      ut.expect( get_items('bad').count ).to_equal(0);
      ut.expect( get_items('!bad').count ).to_equal(3);
      ut.expect( get_items('!context_tag').count ).to_equal(0);
      ut.expect( get_items('context_tag').count ).to_equal(3);
      ut.expect( get_items('!test_tag').count ).to_equal(0);
      ut.expect( get_items('test_tag').count ).to_equal(3);
  end;

end test_ut_suite_tag_filter;
/
