create or replace package body test_suite_builder is

  function invoke_builder_for_annotations(
    a_annotations ut3.ut_annotations,
    a_package_name varchar2 := 'TEST_SUITE_BUILDER_PACKAGE'
  ) return clob is
    l_suites ut3.ut_suite_builder.tt_schema_suites;
    l_suite  ut3.ut_logical_suite;
    l_cursor sys_refcursor;
    l_xml    xmltype;
  begin
    open l_cursor for select value(x) from table(
               ut3.ut_annotated_objects(
                   ut3.ut_annotated_object('UT3_TESTER', a_package_name, 'PACKAGE', a_annotations)
               ) ) x;
    l_suites := ut3.ut_suite_builder.build_suites(l_cursor).schema_suites;
    l_suite  := l_suites(l_suites.first);

    select deletexml(
             xmltype(l_suite),
             '//RESULTS_COUNT|//START_TIME|//END_TIME|//RESULT|//ASSOCIATED_EVENT_NAME' ||
             '|//TRANSACTION_INVALIDATORS|//ERROR_BACKTRACE|//ERROR_STACK|//SERVEROUTPUT'
           )
      into l_xml
      from dual;

    return l_xml.getClobVal();
  end;

  procedure no_suite_description is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite',null, null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_match(
        '<OBJECT_OWNER>UT3_TESTER</OBJECT_OWNER><OBJECT_NAME>some_package</OBJECT_NAME><NAME>some_package</NAME>(<DESCRIPTION/>)?\s*<PATH>some_package</PATH>'
    );
  end;

  procedure suite_description_from_suite is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Some description', null),
        ut3.ut_annotation(2, 'suite','Another description', null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<NAME>some_package</NAME><DESCRIPTION>Another description</DESCRIPTION>%'
    );
  end;

  procedure suitepath_from_non_empty_path is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite',null, null),
        ut3.ut_annotation(2, 'suitepath','dummy.utplsql.some', null),
        ut3.ut_annotation(3, 'suitepath','org.utplsql.some', null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<PATH>org.utplsql.some</PATH>%'
    );
  end;

  procedure suite_descr_from_displayname is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Some description', null),
        ut3.ut_annotation(2, 'suite','Another description', null),
        ut3.ut_annotation(3, 'displayname','New description', null),
        ut3.ut_annotation(4, 'displayname','Newest description', null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<NAME>some_package</NAME><DESCRIPTION>Newest description</DESCRIPTION>%'
    );
  end;

  procedure rollback_type_valid is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite',null, null),
        ut3.ut_annotation(2, 'rollback','bad', null),
        ut3.ut_annotation(3, 'rollback','manual', null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<ROLLBACK_TYPE>'||ut3.ut_utils.gc_rollback_manual||'</ROLLBACK_TYPE>%'
    );
  end;

  procedure rollback_type_duplicated is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite',null, null),
        ut3.ut_annotation(2, 'rollback','bad', null),
        ut3.ut_annotation(3, 'rollback','manual', null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<WARNINGS>%&quot;--%rollback&quot;%</WARNINGS>%'
    );
  end;

  procedure suite_annot_duplicated is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Blah', null),
        ut3.ut_annotation(2, 'suite','Cool', null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<DESCRIPTION>Cool</DESCRIPTION>%<WARNINGS>%&quot;--%suite&quot;%</WARNINGS>%'
    );
  end;

  procedure suitepath_annot_duplicated is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(2, 'suitepath','dummy.utplsql.some', null),
        ut3.ut_annotation(3, 'suitepath','org.utplsql.some', null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<WARNINGS>%&quot;--%suitepath&quot;%</WARNINGS>%'
    );
  end;

  procedure displayname_annot_duplicated is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(3, 'displayname','New description', null),
        ut3.ut_annotation(4, 'displayname','Newest description', null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<WARNINGS>%&quot;--%displayname&quot;%</WARNINGS>%'
    );
  end;

  procedure suitepath_annot_empty is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(3, 'suitepath',null, null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<WARNINGS>%&quot;--%suitepath&quot; annotation requires a non-empty value.%</WARNINGS>%'
    );
  end;

  procedure suitepath_annot_invalid_path is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(2, 'suitepath','path with spaces', null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<WARNINGS>%Invalid path value in annotation &quot;--%suitepath(path with spaces)&quot;%</WARNINGS>%'
    );
  end;

  procedure displayname_annot_empty is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(3, 'displayname',null, null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<WARNINGS>%&quot;--%displayname&quot; annotation requires a non-empty value.%</WARNINGS>%'
    );
  end;

  procedure rollback_type_empty is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(3, 'rollback',null, null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<WARNINGS>%&quot;--%rollback&quot; annotation requires one of values:%</WARNINGS>%'
    );
  end;

  procedure rollback_type_invalid is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(2, 'rollback','bad', null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<WARNINGS>%&quot;--%rollback&quot; annotation requires one of values:%</WARNINGS>%'
    );
  end;

  procedure multiple_before_after is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(2, 'beforeall',null, 'first_before_all'),
        ut3.ut_annotation(3, 'beforeall',null, 'another_before_all'),
        ut3.ut_annotation(4, 'beforeeach',null, 'first_bfore_each'),
        ut3.ut_annotation(5, 'beforeeach',null, 'another_before_each'),
        ut3.ut_annotation(6, 'aftereach',null, 'first_after_each'),
        ut3.ut_annotation(7, 'aftereach',null, 'another_after_each'),
        ut3.ut_annotation(8, 'afterall',null, 'first_after_all'),
        ut3.ut_annotation(9, 'afterall',null, 'another_after_all'),
        ut3.ut_annotation(10, 'test','A test', 'some_test'),
        ut3.ut_annotation(11, 'beforetest','before_test_proc', 'some_test'),
        ut3.ut_annotation(12, 'beforetest','before_test_proc2', 'some_test'),
        ut3.ut_annotation(13, 'aftertest','after_test_proc', 'some_test'),
        ut3.ut_annotation(14, 'aftertest','after_test_proc2', 'some_test')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
      '%<UT_SUITE_ITEM>%<OBJECT_NAME>some_package</OBJECT_NAME>%<NAME>some_test</NAME>' ||
      '%<BEFORE_EACH_LIST>' ||
      '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>first_bfore_each</PROCEDURE_NAME>' ||
      '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>another_before_each</PROCEDURE_NAME>' ||
      '%</BEFORE_EACH_LIST>' ||
      '%<BEFORE_TEST_LIST>' ||
      '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>before_test_proc</PROCEDURE_NAME>' ||
      '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>before_test_proc2</PROCEDURE_NAME>' ||
      '%</BEFORE_TEST_LIST>' ||
      '%<AFTER_TEST_LIST>' ||
      '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>after_test_proc</PROCEDURE_NAME>' ||
      '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>after_test_proc2</PROCEDURE_NAME>' ||
      '%</AFTER_TEST_LIST>' ||
      '%<AFTER_EACH_LIST>' ||
      '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>first_after_each</PROCEDURE_NAME>' ||
      '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>another_after_each</PROCEDURE_NAME>' ||
      '%</AFTER_EACH_LIST>' ||
      '%</UT_SUITE_ITEM>' ||
      '%<BEFORE_ALL_LIST>' ||
      '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>first_before_all</PROCEDURE_NAME>' ||
      '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>another_before_all</PROCEDURE_NAME>' ||
      '%</BEFORE_ALL_LIST>' ||
      '%<AFTER_ALL_LIST>' ||
      '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>first_after_all</PROCEDURE_NAME>' ||
      '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>another_after_all</PROCEDURE_NAME>' ||
      '%</AFTER_ALL_LIST>%'
    );
  end;

  procedure before_after_on_single_proc is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(2, 'beforeall',null, 'do_stuff'),
        ut3.ut_annotation(3, 'beforeeach',null, 'do_stuff'),
        ut3.ut_annotation(4, 'aftereach',null, 'do_stuff'),
        ut3.ut_annotation(5, 'afterall',null, 'do_stuff'),
        ut3.ut_annotation(6, 'test','A test', 'some_test')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
      '%<UT_SUITE_ITEM>%<OBJECT_NAME>some_package</OBJECT_NAME>%<NAME>some_test</NAME>' ||
      '%<BEFORE_EACH_LIST>' ||
      '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>do_stuff</PROCEDURE_NAME>' ||
      '%</BEFORE_EACH_LIST>' ||
      '%<AFTER_EACH_LIST>' ||
      '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>do_stuff</PROCEDURE_NAME>' ||
      '%</AFTER_EACH_LIST>' ||
      '%</UT_SUITE_ITEM>' ||
      '%<BEFORE_ALL_LIST>' ||
      '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>do_stuff</PROCEDURE_NAME>' ||
      '%</BEFORE_ALL_LIST>' ||
      '%<AFTER_ALL_LIST>' ||
      '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>do_stuff</PROCEDURE_NAME>' ||
      '%</AFTER_ALL_LIST>%'
    );
  end;

  procedure before_after_mixed_with_test is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(2, 'beforeall',null, 'do_stuff'),
        ut3.ut_annotation(3, 'beforeeach',null, 'do_stuff'),
        ut3.ut_annotation(4, 'aftereach',null, 'do_stuff'),
        ut3.ut_annotation(5, 'afterall',null, 'do_stuff'),
        ut3.ut_annotation(6, 'test','A test', 'do_stuff')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '<UT_LOGICAL_SUITE><SELF_TYPE>UT_SUITE</SELF_TYPE><OBJECT_OWNER>UT3_TESTER</OBJECT_OWNER>' ||
        '<OBJECT_NAME>some_package</OBJECT_NAME><NAME>some_package</NAME><DESCRIPTION>Cool</DESCRIPTION>' ||
        '%<WARNINGS><VARCHAR2>Annotations: &quot;--\%afterall&quot;, &quot;--\%aftereach&quot;, &quot;--\%beforeall&quot;, &quot;--\%beforeeach&quot;' ||
        ' were ignored for procedure &quot;DO_STUFF&quot;.' ||
        ' Those annotations cannot be used with annotation: &quot;--\%test&quot;</VARCHAR2></WARNINGS>'||
        '%<UT_SUITE_ITEM>%<OBJECT_NAME>some_package</OBJECT_NAME>%<NAME>do_stuff</NAME>%</UT_LOGICAL_SUITE>'
        ,'\'
    );
    ut.expect(l_actual).not_to_be_like('%<BEFORE_EACH_LIST>%');
    ut.expect(l_actual).not_to_be_like('%<AFTER_EACH_LIST>%');
    ut.expect(l_actual).not_to_be_like('%<BEFORE_ALL_LIST>%');
    ut.expect(l_actual).not_to_be_like('%<AFTER_ALL_LIST>%');
  end;

  procedure suite_from_context is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(2, 'beforeall',null, 'suite_level_beforeall'),
        ut3.ut_annotation(3, 'test','In suite', 'suite_level_test'),
        ut3.ut_annotation(4, 'context','A context', null),
        ut3.ut_annotation(5, 'beforeall',null, 'context_setup'),
        ut3.ut_annotation(7, 'test', 'In context', 'test_in_a_context'),
        ut3.ut_annotation(8, 'endcontext',null, null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
      '%<UT_LOGICAL_SUITE>' ||
        '%<WARNINGS/>' ||
        '%<ITEMS>' ||
          '<UT_SUITE_ITEM>' ||
            '%<NAME>context_1</NAME><DESCRIPTION>A context</DESCRIPTION><PATH>some_package.context_1</PATH>' ||
            '%<ITEMS>' ||
              '<UT_SUITE_ITEM>' ||
                '%<NAME>test_in_a_context</NAME><DESCRIPTION>In context</DESCRIPTION><PATH>some_package.context_1.test_in_a_context</PATH>' ||
              '%</UT_SUITE_ITEM>' ||
            '</ITEMS>' ||
            '<BEFORE_ALL_LIST>' ||
            '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>context_setup</PROCEDURE_NAME>' ||
            '%</BEFORE_ALL_LIST>' ||
            '<AFTER_ALL_LIST/>' ||
          '</UT_SUITE_ITEM>' ||
          '<UT_SUITE_ITEM>' ||
            '%<NAME>suite_level_test</NAME><DESCRIPTION>In suite</DESCRIPTION><PATH>some_package.suite_level_test</PATH>' ||
          '%</UT_SUITE_ITEM>' ||
        '</ITEMS>' ||
        '<BEFORE_ALL_LIST>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>suite_level_beforeall</PROCEDURE_NAME>' ||
        '%</BEFORE_ALL_LIST>' ||
        '<AFTER_ALL_LIST/>' ||
      '</UT_LOGICAL_SUITE>'
    );
  end;

  procedure before_after_in_context is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(2, 'test','In suite', 'suite_level_test'),
        ut3.ut_annotation(3, 'context','A context', null),
        ut3.ut_annotation(4, 'beforeall',null, 'context_beforeall'),
        ut3.ut_annotation(5, 'beforeeach',null, 'context_beforeeach'),
        ut3.ut_annotation(6, 'test', 'In context', 'test_in_a_context'),
        ut3.ut_annotation(7, 'aftereach',null, 'context_aftereach'),
        ut3.ut_annotation(8, 'afterall',null, 'context_afterall'),
        ut3.ut_annotation(9, 'endcontext',null, null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
      '<UT_LOGICAL_SUITE>' ||
        '%<ITEMS>' ||
          '%<UT_SUITE_ITEM>' ||
            '%<NAME>context_1</NAME>' ||
            '%<ITEMS>' ||
              '%<UT_SUITE_ITEM>' ||
                '%<NAME>test_in_a_context</NAME>' ||
                '%<BEFORE_EACH_LIST>%<PROCEDURE_NAME>context_beforeeach</PROCEDURE_NAME>%</BEFORE_EACH_LIST>' ||
                '%<ITEM>%<PROCEDURE_NAME>test_in_a_context</PROCEDURE_NAME>%</ITEM>' ||
                '%<AFTER_EACH_LIST>%<PROCEDURE_NAME>context_aftereach</PROCEDURE_NAME>%</AFTER_EACH_LIST>' ||
              '%</UT_SUITE_ITEM>' ||
            '%</ITEMS>' ||
            '%<BEFORE_ALL_LIST>%<PROCEDURE_NAME>context_beforeall</PROCEDURE_NAME>%</BEFORE_ALL_LIST>' ||
            '%<AFTER_ALL_LIST>%<PROCEDURE_NAME>context_afterall</PROCEDURE_NAME>%</AFTER_ALL_LIST>' ||
          '%</UT_SUITE_ITEM>' ||
          '%<UT_SUITE_ITEM>' ||
            '%<NAME>suite_level_test</NAME>' ||
            '%<ITEM>%<PROCEDURE_NAME>suite_level_test</PROCEDURE_NAME>%</ITEM>' ||
          '%</UT_SUITE_ITEM>' ||
        '%</ITEMS>' ||
      '%</UT_LOGICAL_SUITE>'
    );
    ut.expect(l_actual).not_to_be_like('%<ITEMS>%<ITEMS>%</ITEMS>%<BEFORE_EACH_LIST>%</ITEMS>%');
    ut.expect(l_actual).not_to_be_like('%<ITEMS>%<ITEMS>%</ITEMS>%<AFTER_EACH_LIST>%</ITEMS>%');
    ut.expect(l_actual).not_to_be_like('%<ITEMS>%<ITEMS>%</ITEMS>%</ITEMS>%<BEFORE_ALL_LIST>%');
    ut.expect(l_actual).not_to_be_like('%<ITEMS>%<ITEMS>%</ITEMS>%</ITEMS>%<AFTER_ALL_LIST>%');
  end;

  procedure before_after_out_of_context is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(2, 'beforeall',null, 'suite_level_beforeall'),
        ut3.ut_annotation(3, 'beforeeach',null, 'suite_level_beforeeach'),
        ut3.ut_annotation(4, 'test','In suite', 'suite_level_test'),
        ut3.ut_annotation(5, 'context','A context', null),
        ut3.ut_annotation(6, 'test', 'In context', 'test_in_a_context'),
        ut3.ut_annotation(7, 'endcontext',null, null),
        ut3.ut_annotation(8, 'aftereach',null, 'suite_level_aftereach'),
        ut3.ut_annotation(9, 'afterall',null, 'suite_level_afterall')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
      '<UT_LOGICAL_SUITE>' ||
        '%<ITEMS>' ||
          '%<UT_SUITE_ITEM>' ||
            '%<NAME>context_1</NAME>' ||
            '%<ITEMS>' ||
              '%<UT_SUITE_ITEM>' ||
                '%<NAME>test_in_a_context</NAME>' ||
                '%<BEFORE_EACH_LIST>%<PROCEDURE_NAME>suite_level_beforeeach</PROCEDURE_NAME>%</BEFORE_EACH_LIST>' ||
                '%<ITEM>%<PROCEDURE_NAME>test_in_a_context</PROCEDURE_NAME>%</ITEM>' ||
                '%<AFTER_EACH_LIST>%<PROCEDURE_NAME>suite_level_aftereach</PROCEDURE_NAME>%</AFTER_EACH_LIST>' ||
              '%</UT_SUITE_ITEM>' ||
            '%</ITEMS>' ||
          '%</UT_SUITE_ITEM>' ||
          '%<UT_SUITE_ITEM>' ||
            '%<NAME>suite_level_test</NAME>' ||
            '%<BEFORE_EACH_LIST>%<PROCEDURE_NAME>suite_level_beforeeach</PROCEDURE_NAME>%</BEFORE_EACH_LIST>' ||
            '%<ITEM>%<PROCEDURE_NAME>suite_level_test</PROCEDURE_NAME>%</ITEM>' ||
            '%<AFTER_EACH_LIST>%<PROCEDURE_NAME>suite_level_aftereach</PROCEDURE_NAME>%</AFTER_EACH_LIST>' ||
          '%</UT_SUITE_ITEM>' ||
        '%</ITEMS>' ||
        '%<BEFORE_ALL_LIST>%<PROCEDURE_NAME>suite_level_beforeall</PROCEDURE_NAME>%</BEFORE_ALL_LIST>' ||
        '%<AFTER_ALL_LIST>%<PROCEDURE_NAME>suite_level_afterall</PROCEDURE_NAME>%</AFTER_ALL_LIST>' ||
      '%</UT_LOGICAL_SUITE>'
    );
    ut.expect(l_actual).not_to_be_like('%<ITEMS>%<ITEMS>%</ITEMS>%<BEFORE_ALL_LIST>%</ITEMS>%');
    ut.expect(l_actual).not_to_be_like('%<ITEMS>%<ITEMS>%</ITEMS>%<AFTER_ALL_LIST>%</ITEMS>%');
  end;

  procedure context_without_endcontext is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(2, 'beforeall',null, 'suite_level_beforeall'),
        ut3.ut_annotation(3, 'test','In suite', 'suite_level_test'),
        ut3.ut_annotation(4, 'context','A context', null),
        ut3.ut_annotation(5, 'beforeall',null, 'context_setup'),
        ut3.ut_annotation(7, 'test', 'In context', 'test_in_a_context')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<WARNINGS><VARCHAR2>Annotation &quot;--\%context(A context)&quot; was ignored. Cannot find following &quot;--\%endcontext&quot;.</VARCHAR2></WARNINGS>%'
        ,'\'
    );
    ut.expect(l_actual).to_be_like(
        '<UT_LOGICAL_SUITE>' ||
        '%<ITEMS>' ||
        '<UT_SUITE_ITEM>' ||
        '%<NAME>suite_level_test</NAME><DESCRIPTION>In suite</DESCRIPTION><PATH>some_package.suite_level_test</PATH>' ||
        '%</UT_SUITE_ITEM>' ||
        '<UT_SUITE_ITEM>' ||
        '%<NAME>test_in_a_context</NAME><DESCRIPTION>In context</DESCRIPTION><PATH>some_package.test_in_a_context</PATH>' ||
        '%</UT_SUITE_ITEM>' ||
        '</ITEMS>' ||
        '<BEFORE_ALL_LIST>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>suite_level_beforeall</PROCEDURE_NAME>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>context_setup</PROCEDURE_NAME>' ||
        '%</BEFORE_ALL_LIST>' ||
        '<AFTER_ALL_LIST/>' ||
        '</UT_LOGICAL_SUITE>'
    );
  end;

  procedure endcontext_without_context is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(2, 'beforeall',null, 'suite_level_beforeall'),
        ut3.ut_annotation(3, 'test','In suite', 'suite_level_test'),
        ut3.ut_annotation(4, 'context','A context', null),
        ut3.ut_annotation(5, 'beforeall',null, 'context_setup'),
        ut3.ut_annotation(7, 'test', 'In context', 'test_in_a_context'),
        ut3.ut_annotation(8, 'endcontext',null, null),
        ut3.ut_annotation(9, 'endcontext',null, null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<WARNINGS><VARCHAR2>Annotation &quot;--\%endcontext&quot; was ignored. Cannot find preceding &quot;--\%context&quot;.</VARCHAR2></WARNINGS>%'
        ,'\'
    );
    ut.expect(l_actual).to_be_like(
      '<UT_LOGICAL_SUITE>' ||
        '%<ITEMS>' ||
          '<UT_SUITE_ITEM>' ||
            '%<NAME>context_1</NAME><DESCRIPTION>A context</DESCRIPTION><PATH>some_package.context_1</PATH>' ||
            '%<ITEMS>' ||
              '<UT_SUITE_ITEM>' ||
                '%<NAME>test_in_a_context</NAME><DESCRIPTION>In context</DESCRIPTION><PATH>some_package.context_1.test_in_a_context</PATH>' ||
              '%</UT_SUITE_ITEM>' ||
            '</ITEMS>' ||
            '<BEFORE_ALL_LIST>' ||
            '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>context_setup</PROCEDURE_NAME>' ||
            '%</BEFORE_ALL_LIST>' ||
            '<AFTER_ALL_LIST/>' ||
          '</UT_SUITE_ITEM>' ||
          '<UT_SUITE_ITEM>' ||
            '%<NAME>suite_level_test</NAME><DESCRIPTION>In suite</DESCRIPTION><PATH>some_package.suite_level_test</PATH>' ||
          '%</UT_SUITE_ITEM>' ||
        '</ITEMS>' ||
        '<BEFORE_ALL_LIST>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>suite_level_beforeall</PROCEDURE_NAME>' ||
        '%</BEFORE_ALL_LIST>' ||
        '<AFTER_ALL_LIST/>' ||
      '</UT_LOGICAL_SUITE>'
    );
  end;

end;
/
