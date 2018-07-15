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
        '%<NAME>some_package</NAME><DESCRIPTION>Some description</DESCRIPTION>%'
    );
  end;

  procedure suitepath_from_non_empty_path is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite',null, null),
        ut3.ut_annotation(2, 'suitepath','org.utplsql.some', null),
        ut3.ut_annotation(3, 'suitepath','dummy.utplsql.some', null)
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
        '%<NAME>some_package</NAME><DESCRIPTION>New description</DESCRIPTION>%'
    );
  end;

  procedure rollback_type_valid is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite',null, null),
        ut3.ut_annotation(2, 'rollback','manual', null),
        ut3.ut_annotation(3, 'rollback','bad', null)
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
        ut3.ut_annotation(2, 'rollback','manual', null),
        ut3.ut_annotation(3, 'rollback','bad', null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<WARNINGS>%&quot;--%rollback&quot;%%UT3_TESTER.SOME_PACKAGE%3%</WARNINGS>%'
    );
  end;

  procedure suite_annot_duplicated is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(2, 'suite','Cool', null),
        ut3.ut_annotation(8, 'suite','bad', null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<DESCRIPTION>Cool</DESCRIPTION>%<WARNINGS>%&quot;--%suite&quot;%UT3_TESTER.SOME_PACKAGE%line 8%</WARNINGS>%'
    );
  end;

  procedure test_annotation is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(2, 'suite','Cool', null),
        ut3.ut_annotation(8, 'test','Some test', 'test_procedure')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<UT_SUITE_ITEM>' ||
        '%<NAME>test_procedure</NAME><DESCRIPTION>Some test</DESCRIPTION><PATH>some_package.test_procedure</PATH>' ||
        '%</UT_SUITE_ITEM>%'
    );
  end;

  procedure test_annot_duplicated is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(2, 'suite','Cool', null),
        ut3.ut_annotation(8, 'test','Some test', 'test_procedure'),
        ut3.ut_annotation(9, 'test','Dup', 'test_procedure')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<DESCRIPTION>Cool</DESCRIPTION>%<WARNINGS>%&quot;--%test&quot;%UT3_TESTER.SOME_PACKAGE.TEST_PROCEDURE%line 9%</WARNINGS>%'
    );
  end;

  procedure beforeall_annot_duplicated is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(2, 'suite','Cool', null),
        ut3.ut_annotation(8, 'beforeall', null, 'test_procedure'),
        ut3.ut_annotation(9, 'beforeall', null, 'test_procedure')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<DESCRIPTION>Cool</DESCRIPTION>%<WARNINGS>%&quot;--%beforeall&quot;%UT3_TESTER.SOME_PACKAGE.TEST_PROCEDURE%line 9%</WARNINGS>%'
    );
  end;

  procedure beforeeach_annot_duplicated is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(2, 'suite','Cool', null),
        ut3.ut_annotation(8, 'beforeeach', null, 'test_procedure'),
        ut3.ut_annotation(9, 'beforeeach', null, 'test_procedure')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<DESCRIPTION>Cool</DESCRIPTION>%<WARNINGS>%&quot;--%beforeeach&quot;%UT3_TESTER.SOME_PACKAGE.TEST_PROCEDURE%line 9%</WARNINGS>%'
    );
  end;

  procedure afterall_annot_duplicated is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(2, 'suite','Cool', null),
        ut3.ut_annotation(8, 'afterall', null, 'test_procedure'),
        ut3.ut_annotation(9, 'afterall', null, 'test_procedure')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<DESCRIPTION>Cool</DESCRIPTION>%<WARNINGS>%&quot;--%afterall&quot;%UT3_TESTER.SOME_PACKAGE.TEST_PROCEDURE%line 9%</WARNINGS>%'
    );
  end;

  procedure aftereach_annot_duplicated is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(2, 'suite','Cool', null),
        ut3.ut_annotation(8, 'aftereach', null, 'test_procedure'),
        ut3.ut_annotation(9, 'aftereach', null, 'test_procedure')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<DESCRIPTION>Cool</DESCRIPTION>%<WARNINGS>%&quot;--%aftereach&quot;%UT3_TESTER.SOME_PACKAGE.TEST_PROCEDURE%line 9%</WARNINGS>%'
    );
  end;

  procedure suitepath_annot_duplicated is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(2, 'suite','Cool', null),
        ut3.ut_annotation(3, 'suitepath','dummy.utplsql.some', null),
        ut3.ut_annotation(4, 'suitepath','org.utplsql.some', null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<WARNINGS>%&quot;--%suitepath&quot;%line 4%</WARNINGS>%'
    );
  end;

  procedure displayname_annot_duplicated is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
      --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(2, 'suite','Cool', null),
        ut3.ut_annotation(4, 'displayname','New description', null),
        ut3.ut_annotation(5, 'displayname','Newest description', null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<WARNINGS>%&quot;--%displayname&quot;%line 5%</WARNINGS>%'
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
        '%<WARNINGS>%&quot;--%suitepath&quot; annotation requires a non-empty parameter value.%</WARNINGS>%'
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
        '%<WARNINGS>%&quot;--%displayname&quot; annotation requires a non-empty parameter value.%</WARNINGS>%'
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
        '%<WARNINGS>%&quot;--%rollback&quot; annotation requires one of values as parameter:%</WARNINGS>%'
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
        '%<WARNINGS>%&quot;--%rollback&quot; annotation requires one of values as parameter: &quot;auto&quot; or &quot;manual&quot;. Annotation ignored.%</WARNINGS>%'
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
        ut3.ut_annotation(14, 'test','A test', 'some_test'),
        ut3.ut_annotation(15, 'beforetest','before_test_proc', 'some_test'),
        ut3.ut_annotation(16, 'beforetest','before_test_proc2', 'some_test'),
        ut3.ut_annotation(18, 'aftertest','after_test_proc', 'some_test'),
        ut3.ut_annotation(20, 'aftertest','after_test_proc2', 'some_test')
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

  procedure multiple_standalone_bef_aft is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(2, 'beforeall', 'some_package.first_before_all',null),
        ut3.ut_annotation(3, 'beforeall', 'different_package.another_before_all',null),
        ut3.ut_annotation(4, 'beforeeach', 'first_before_each',null),
        ut3.ut_annotation(5, 'beforeeach', 'different_owner.different_package.another_before_each',null),
        ut3.ut_annotation(6, 'aftereach', 'first_after_each',null),
        ut3.ut_annotation(7, 'aftereach', 'another_after_each,different_owner.different_package.one_more_after_each',null),
        ut3.ut_annotation(8, 'afterall', 'first_after_all',null),
        ut3.ut_annotation(9, 'afterall', 'another_after_all',null),
        ut3.ut_annotation(14, 'test','A test', 'some_test'),
        ut3.ut_annotation(15, 'beforetest','before_test_proc', 'some_test'),
        ut3.ut_annotation(16, 'beforetest','before_test_proc2', 'some_test'),
        ut3.ut_annotation(18, 'aftertest','after_test_proc', 'some_test'),
        ut3.ut_annotation(20, 'aftertest','after_test_proc2', 'some_test')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<UT_SUITE_ITEM>%<OBJECT_NAME>some_package</OBJECT_NAME>%<NAME>some_test</NAME>' ||
        '%<BEFORE_EACH_LIST>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>first_before_each</PROCEDURE_NAME>' ||
        '%<OWNER_NAME>different_owner</OWNER_NAME><OBJECT_NAME>different_package</OBJECT_NAME><PROCEDURE_NAME>another_before_each</PROCEDURE_NAME>' ||
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
        '%<OWNER_NAME>different_owner</OWNER_NAME><OBJECT_NAME>different_package</OBJECT_NAME><PROCEDURE_NAME>one_more_after_each</PROCEDURE_NAME>' ||
        '%</AFTER_EACH_LIST>' ||
        '%</UT_SUITE_ITEM>' ||
        '%<BEFORE_ALL_LIST>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>first_before_all</PROCEDURE_NAME>' ||
        '%<OBJECT_NAME>different_package</OBJECT_NAME><PROCEDURE_NAME>another_before_all</PROCEDURE_NAME>' ||
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

  procedure multiple_mixed_bef_aft is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(2, 'beforeall', null,'first_before_all'),
        ut3.ut_annotation(3, 'beforeall', 'different_package.another_before_all',null),
        ut3.ut_annotation(4, 'beforeeach', 'first_before_each',null),
        ut3.ut_annotation(5, 'beforeeach', 'different_owner.different_package.another_before_each',null),
        ut3.ut_annotation(6, 'aftereach', null, 'first_after_each'),
        ut3.ut_annotation(7, 'aftereach', 'another_after_each,different_owner.different_package.one_more_after_each',null),
        ut3.ut_annotation(8, 'afterall', 'first_after_all',null),
        ut3.ut_annotation(9, 'afterall', 'another_after_all',null),
        ut3.ut_annotation(14, 'test','A test', 'some_test'),
        ut3.ut_annotation(15, 'beforetest','before_test_proc', 'some_test'),
        ut3.ut_annotation(16, 'beforetest','before_test_proc2', 'some_test'),
        ut3.ut_annotation(18, 'aftertest','after_test_proc', 'some_test'),
        ut3.ut_annotation(20, 'aftertest','after_test_proc2', 'some_test'),
        ut3.ut_annotation(21, 'beforeall', null,'last_before_all'),
        ut3.ut_annotation(22, 'aftereach', null, 'last_after_each'),
        ut3.ut_annotation(23, 'afterall', null, 'last_after_all')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<UT_SUITE_ITEM>%<OBJECT_NAME>some_package</OBJECT_NAME>%<NAME>some_test</NAME>' ||
        '%<BEFORE_EACH_LIST>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>first_before_each</PROCEDURE_NAME>' ||
        '%<OWNER_NAME>different_owner</OWNER_NAME><OBJECT_NAME>different_package</OBJECT_NAME><PROCEDURE_NAME>another_before_each</PROCEDURE_NAME>' ||
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
        '%<OWNER_NAME>different_owner</OWNER_NAME><OBJECT_NAME>different_package</OBJECT_NAME><PROCEDURE_NAME>one_more_after_each</PROCEDURE_NAME>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>last_after_each</PROCEDURE_NAME>' ||
        '%</AFTER_EACH_LIST>' ||
        '%</UT_SUITE_ITEM>' ||
        '%<BEFORE_ALL_LIST>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>first_before_all</PROCEDURE_NAME>' ||
        '%<OBJECT_NAME>different_package</OBJECT_NAME><PROCEDURE_NAME>another_before_all</PROCEDURE_NAME>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>last_before_all</PROCEDURE_NAME>' ||
        '%</BEFORE_ALL_LIST>' ||
        '%<AFTER_ALL_LIST>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>first_after_all</PROCEDURE_NAME>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>another_after_all</PROCEDURE_NAME>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>last_after_all</PROCEDURE_NAME>' ||
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
    ut.expect(l_actual).to_be_like('%<WARNINGS>%Annotation &quot;--\%beforeall&quot;%line 2%</WARNINGS>%', '\');
    ut.expect(l_actual).to_be_like('%<WARNINGS>%Annotation &quot;--\%beforeeach&quot;%line 3%</WARNINGS>%', '\');
    ut.expect(l_actual).to_be_like('%<WARNINGS>%Annotation &quot;--\%aftereach&quot;%line 4%</WARNINGS>%', '\');
    ut.expect(l_actual).to_be_like('%<WARNINGS>%Annotation &quot;--\%afterall&quot; cannot be used with &quot;--\%test&quot;. Annotation ignored.'
                                   ||'%at &quot;UT3_TESTER.SOME_PACKAGE.DO_STUFF&quot;, line 5%</WARNINGS>%', '\');
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
        ut3.ut_annotation(4, 'context','a_context', null),
        ut3.ut_annotation(5, 'displayname','A context', null),
        ut3.ut_annotation(6, 'beforeall',null, 'context_setup'),
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
            '%<NAME>a_context</NAME><DESCRIPTION>A context</DESCRIPTION><PATH>some_package.a_context</PATH>' ||
            '%<ITEMS>' ||
              '<UT_SUITE_ITEM>' ||
                '%<NAME>test_in_a_context</NAME><DESCRIPTION>In context</DESCRIPTION><PATH>some_package.a_context.test_in_a_context</PATH>' ||
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
        ut3.ut_annotation(1, 'suite', 'Cool', null),
        ut3.ut_annotation(2, 'test', 'In suite', 'suite_level_test'),
        ut3.ut_annotation(3, 'context', 'a_context', null),
        ut3.ut_annotation(4, 'beforeall', 'context_beforeall', null),
        ut3.ut_annotation(5, 'beforeeach', null, 'context_beforeeach'),
        ut3.ut_annotation(6, 'test', 'In context', 'test_in_a_context'),
        ut3.ut_annotation(7, 'aftereach', 'context_aftereach' ,null),
        ut3.ut_annotation(8, 'afterall', null, 'context_afterall'),
        ut3.ut_annotation(9, 'endcontext', null, null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
      '<UT_LOGICAL_SUITE>' ||
        '%<ITEMS>' ||
          '%<UT_SUITE_ITEM>' ||
            '%<NAME>a_context</NAME>' ||
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
        ut3.ut_annotation(5, 'context','a_context', null),
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
            '%<NAME>a_context</NAME>' ||
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
        '%<WARNINGS><VARCHAR2>Invalid annotation &quot;--\%context&quot;. Cannot find following &quot;--\%endcontext&quot;. Annotation ignored.%at &quot;UT3_TESTER.SOME_PACKAGE&quot;, line 4</VARCHAR2></WARNINGS>%'
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
        ut3.ut_annotation(4, 'context','a_context', null),
        ut3.ut_annotation(5, 'displayname','A context', null),
        ut3.ut_annotation(6, 'beforeall',null, 'context_setup'),
        ut3.ut_annotation(7, 'test', 'In context', 'test_in_a_context'),
        ut3.ut_annotation(8, 'endcontext',null, null),
        ut3.ut_annotation(9, 'endcontext',null, null)
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<WARNINGS><VARCHAR2>Invalid annotation &quot;--\%endcontext&quot;. Cannot find preceding &quot;--\%context&quot;. Annotation ignored.%at &quot;UT3_TESTER.SOME_PACKAGE&quot;, line 9</VARCHAR2></WARNINGS>%'
        ,'\'
    );
    ut.expect(l_actual).to_be_like(
      '<UT_LOGICAL_SUITE>' ||
        '%<ITEMS>' ||
          '<UT_SUITE_ITEM>' ||
            '%<NAME>a_context</NAME><DESCRIPTION>A context</DESCRIPTION><PATH>some_package.a_context</PATH>' ||
            '%<ITEMS>' ||
              '<UT_SUITE_ITEM>' ||
                '%<NAME>test_in_a_context</NAME><DESCRIPTION>In context</DESCRIPTION><PATH>some_package.a_context.test_in_a_context</PATH>' ||
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

  procedure throws_value_empty is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(3, 'test','A test with empty throws annotation', 'A_TEST_PROCEDURE'),
        ut3.ut_annotation(3, 'throws',null, 'A_TEST_PROCEDURE')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<WARNINGS>%&quot;--%throws&quot; annotation requires a parameter. Annotation ignored.%</WARNINGS>%'
    );
  end;

  procedure throws_value_invalid is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(3, 'test','A test with invalid throws annotation', 'A_TEST_PROCEDURE'),
        ut3.ut_annotation(3, 'throws',' -20145 , bad_variable_name ', 'A_TEST_PROCEDURE')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<WARNINGS>%Invalid parameter value &quot;bad_variable_name&quot; for &quot;--%throws&quot; annotation. Parameter ignored.%</WARNINGS>%'
    );
  end;


  procedure before_aftertest_multi is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(14, 'test','A test', 'some_test'),
        ut3.ut_annotation(15, 'beforetest','before_test_proc', 'some_test'),
        ut3.ut_annotation(16, 'beforetest','before_test_proc2', 'some_test'),
        ut3.ut_annotation(18, 'aftertest','after_test_proc', 'some_test'),
        ut3.ut_annotation(20, 'aftertest','after_test_proc2', 'some_test')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<UT_SUITE_ITEM>%<OBJECT_NAME>some_package</OBJECT_NAME>%<NAME>some_test</NAME>' ||
        '%<BEFORE_TEST_LIST>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>before_test_proc</PROCEDURE_NAME>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>before_test_proc2</PROCEDURE_NAME>' ||
        '%</BEFORE_TEST_LIST>' ||
        '%<AFTER_TEST_LIST>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>after_test_proc</PROCEDURE_NAME>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>after_test_proc2</PROCEDURE_NAME>' ||
        '%</AFTER_TEST_LIST>' ||
        '%</UT_SUITE_ITEM>%'
    );
  end;

  procedure before_aftertest_twice is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(14, 'test','A test', 'some_test'),
        ut3.ut_annotation(15, 'beforetest','before_test_proc, before_test_proc2', 'some_test'),
        ut3.ut_annotation(16, 'beforetest','before_test_proc3', 'some_test'),
        ut3.ut_annotation(18, 'aftertest','after_test_proc,after_test_proc2', 'some_test'),
        ut3.ut_annotation(20, 'aftertest','after_test_proc3', 'some_test')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<UT_SUITE_ITEM>%<OBJECT_NAME>some_package</OBJECT_NAME>%<NAME>some_test</NAME>' ||
        '%<BEFORE_TEST_LIST>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>before_test_proc</PROCEDURE_NAME>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>before_test_proc2</PROCEDURE_NAME>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>before_test_proc3</PROCEDURE_NAME>' ||
        '%</BEFORE_TEST_LIST>' ||
        '%<AFTER_TEST_LIST>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>after_test_proc</PROCEDURE_NAME>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>after_test_proc2</PROCEDURE_NAME>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>after_test_proc3</PROCEDURE_NAME>' ||
        '%</AFTER_TEST_LIST>' ||
        '%</UT_SUITE_ITEM>%'
    );
  end;

  procedure before_aftertest_pkg_proc is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(14, 'test','A test', 'some_test'),
        ut3.ut_annotation(15, 'beforetest','external_package.before_test_proc', 'some_test'),
        ut3.ut_annotation(18, 'aftertest','external_package.after_test_proc', 'some_test')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<UT_SUITE_ITEM>%<OBJECT_NAME>some_package</OBJECT_NAME>%<NAME>some_test</NAME>' ||
        '%<BEFORE_TEST_LIST>' ||
        '%<OBJECT_NAME>external_package</OBJECT_NAME><PROCEDURE_NAME>before_test_proc</PROCEDURE_NAME>' ||
        '%</BEFORE_TEST_LIST>' ||
        '%<AFTER_TEST_LIST>' ||
        '%<OBJECT_NAME>external_package</OBJECT_NAME><PROCEDURE_NAME>after_test_proc</PROCEDURE_NAME>' ||
        '%</AFTER_TEST_LIST>' ||
        '%</UT_SUITE_ITEM>%'
    );
  end;

  procedure before_aftertest_mixed_syntax is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(14, 'test','A test', 'some_test'),
        ut3.ut_annotation(15, 'beforetest','external_package.before_test_proc, before_test_proc2', 'some_test'),
        ut3.ut_annotation(18, 'aftertest','external_package.after_test_proc, after_test_proc2', 'some_test')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<UT_SUITE_ITEM>%<OBJECT_NAME>some_package</OBJECT_NAME>%<NAME>some_test</NAME>' ||
        '%<BEFORE_TEST_LIST>' ||
        '%<OBJECT_NAME>external_package</OBJECT_NAME><PROCEDURE_NAME>before_test_proc</PROCEDURE_NAME>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>before_test_proc2</PROCEDURE_NAME>' ||
        '%</BEFORE_TEST_LIST>' ||
        '%<AFTER_TEST_LIST>' ||
        '%<OBJECT_NAME>external_package</OBJECT_NAME><PROCEDURE_NAME>after_test_proc</PROCEDURE_NAME>' ||
        '%<OBJECT_NAME>some_package</OBJECT_NAME><PROCEDURE_NAME>after_test_proc2</PROCEDURE_NAME>' ||
        '%</AFTER_TEST_LIST>' ||
        '%</UT_SUITE_ITEM>%'
    );
  end;

  procedure test_annotation_ordering is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    --Arrange
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite','Cool', null),
        ut3.ut_annotation(4, 'test','B test', 'b_test'),
        ut3.ut_annotation(10, 'test','Z test', 'z_test'),
        ut3.ut_annotation(14, 'test','A test', 'a_test')
    );
    --Act
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    --Assert
    ut.expect(l_actual).to_be_like(
        '%<UT_SUITE_ITEM>%<OBJECT_NAME>some_package</OBJECT_NAME>%<NAME>b_test</NAME>' ||
        '%</UT_SUITE_ITEM>%'||
        '%<UT_SUITE_ITEM>%<OBJECT_NAME>some_package</OBJECT_NAME>%<NAME>z_test</NAME>' ||
        '%</UT_SUITE_ITEM>%'||
        '%<UT_SUITE_ITEM>%<OBJECT_NAME>some_package</OBJECT_NAME>%<NAME>a_test</NAME>' ||
        '%</UT_SUITE_ITEM>%'
    );
  end;

end;
/
