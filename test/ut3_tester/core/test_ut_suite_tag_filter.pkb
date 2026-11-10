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

  procedure is_matching_is_cached_in_sql is
    --the anonymous block run by is_matching for the expression 'cache_probe'
    c_block  constant varchar2(100) := 'declare %ut_varchar2_list := :a_tags;%''cache_probe'' member of %';
    l_before number;
    l_after  number;
    l_count  integer;
  begin
    l_before := ut3_tester_helper.main_helper.get_sql_executions(c_block);
    --1000 rows with 3 distinct sets of tags
    select count(*) into l_count
      from (select mod(level,3) k from dual connect by level <= 1000)
     where ut3_develop.ut_suite_tag_filter.is_matching('t'||k||',x', 'cache_probe') = 0;
    l_after := ut3_tester_helper.main_helper.get_sql_executions(c_block);
    ut.expect( l_count ).to_equal(1000);
    --at least one execution, so the pattern above still matches the block
    ut.expect( l_after - l_before ).to_be_between(1, 3);
  end;

  procedure is_matching_invalid_expression is
    l_result integer;
  begin
    l_result := ut3_develop.ut_suite_tag_filter.is_matching('slow', 'slow&|db');
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
