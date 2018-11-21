create or replace package body test_coveralls_reporter is

  procedure report_on_file is
    l_results   ut3.ut_varchar2_list;
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected := q'[{"source_files":[
{ "name": "test/ut3.dummy_coverage.pkb",
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
    --Act
    select *
      bulk collect into l_results
      from table(
        ut3.ut.run(
          a_path => 'ut3.test_dummy_coverage',
          a_reporter=> ut3.ut_coveralls_reporter( ),
          a_source_files => ut3.ut_varchar2_list( 'test/ut3.dummy_coverage.pkb' ),
          a_test_files => ut3.ut_varchar2_list( )
        )
      );
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_equal(l_expected);
  end;

  procedure report_zero_coverage is
    l_results   ut3.ut_varchar2_list;
    l_expected  clob;
    l_actual    clob;
    pragma autonomous_transaction;
  begin
    --Arrange
    l_expected := q'[{"source_files":[
{ "name": "ut3.dummy_coverage",
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

    test_coverage.cleanup_dummy_coverage;

    --Act
    select *
    bulk collect into l_results
    from table(
      ut3.ut.run(
          'ut3.test_dummy_coverage',
          ut3.ut_coveralls_reporter(),
          a_include_objects => ut3.ut_varchar2_list('UT3.DUMMY_COVERAGE')
      )
    );
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_equal(l_expected);

    test_coverage.setup_dummy_coverage;

  end;

end;
/
