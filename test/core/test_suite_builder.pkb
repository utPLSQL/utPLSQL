create or replace package body test_suite_builder is

  function invoke_builder_for_annotations(
    a_annotations ut3.ut_annotations,
    a_package_name varchar2 := 'TEST_SUITE_BUILDER_PACKAGE'
  ) return clob is
    l_suites ut3.ut_suite_builder.tt_schema_suites;
    l_cursor sys_refcursor;
  begin
    open l_cursor for select value(x) from table(
               ut3.ut_annotated_objects(
                   ut3.ut_annotated_object('UT3_TESTER', a_package_name, 'PACKAGE', a_annotations)
               ) ) x;
    l_suites := ut3.ut_suite_builder.build_suites(l_cursor).schema_suites;
    return xmltype(l_suites(l_suites.first)).getClobVal();
  end;

  procedure no_suite_description is
    l_actual      clob;
    l_annotations ut3.ut_annotations;
  begin
    l_annotations := ut3.ut_annotations(
        ut3.ut_annotation(1, 'suite',null, null)
    );
    l_actual := invoke_builder_for_annotations(l_annotations, 'SOME_PACKAGE');
    ut.expect(l_actual).to_be_like('%<OBJECT_OWNER>UT3_TESTER</OBJECT_OWNER><OBJECT_NAME>some_package</OBJECT_NAME><NAME>some_package</NAME><DESCRIPTION/>%');
  end;


end;
/
