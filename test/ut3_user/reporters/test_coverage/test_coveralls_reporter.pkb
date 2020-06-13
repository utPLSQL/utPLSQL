create or replace package body test_coveralls_reporter is

  procedure report_on_file is
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected := q'[{"source_files":[
{ "name": "test/ut3_develop.dummy_coverage.pkb",
"coverage": [
null,
null,
null,
1,
0,
null,
1
]
}
]}
 ]';
    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              a_path => 'ut3_develop.test_dummy_coverage',
              a_reporter => ut3_develop.ut_coveralls_reporter( ),
              a_source_files => ut3_develop.ut_varchar2_list( 'test/ut3_develop.dummy_coverage.pkb' ),
              a_test_files => ut3_develop.ut_varchar2_list( )
            )
          ]'
      );
    --Assert
    ut.expect(l_actual).to_equal(l_expected);
  end;

  procedure report_zero_coverage is
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected := q'[{"source_files":[
{ "name": "ut3_develop.dummy_coverage",
"coverage": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
]
}
]}
 ]';

    --Act
    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              'ut3_develop.test_dummy_coverage.zero_coverage',
              ut3_develop.ut_coveralls_reporter(),
              a_include_objects => ut3_develop.ut_varchar2_list('UT3_DEVELOP.DUMMY_COVERAGE')
            )
          ]'
        );
    --Assert
    ut.expect(l_actual).to_equal(l_expected);

  end;

end;
/
