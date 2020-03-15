create or replace package body test_proftab_coverage is

  procedure coverage_for_object is
    l_expected  clob;
    l_actual    clob;
    l_results   ut3_develop.ut_varchar2_list;
  begin
    --Arrange
    l_expected := '%<file path="ut3_develop.dummy_coverage">%';
    --Act
    select *
      bulk collect into l_results
      from table(
        ut3_develop.ut.run(
          a_path => 'ut3_develop.test_dummy_coverage',
          a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
          a_include_objects => ut3_develop.ut_varchar2_list( 'ut3_develop.dummy_coverage' )
        )
      );
    --Assert
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure coverage_for_object_no_owner is
    l_expected  clob;
    l_actual    clob;
    l_results   ut3_develop.ut_varchar2_list;
  begin
    --Arrange
    l_expected := '%<file path="ut3_develop.dummy_coverage">%';
    --Act
    select *
      bulk collect into l_results
      from table(
        ut3_develop.ut.run(
          a_path => 'ut3_develop.test_dummy_coverage',
          a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
          a_include_objects => ut3_develop.ut_varchar2_list( 'dummy_coverage' )
        )
      );
    --Assert
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure coverage_for_schema is
    l_expected  clob;
    l_actual    clob;
    l_results   ut3_develop.ut_varchar2_list;
  begin
    --Arrange
    l_expected := '<file path="ut3_develop.%">';
    l_expected := '%'||l_expected||'%'||l_expected||'%';
    --Act
    select *
      bulk collect into l_results
      from table(
        ut3_develop.ut.run(
          a_path => 'ut3_develop.test_dummy_coverage',
          a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
          a_coverage_schemes => ut3_develop.ut_varchar2_list( 'ut3_develop' )
        )
      );
    --Assert
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure coverage_for_file is
    l_expected  clob;
    l_actual    clob;
    l_results   ut3_develop.ut_varchar2_list;
    l_file_path varchar2(100);
  begin
    --Arrange
    l_file_path := lower('test/ut3_develop.dummy_coverage.pkb');
    l_expected := '%<file path="'||l_file_path||'">%';
    --Act
    select *
      bulk collect into l_results
      from table(
        ut3_develop.ut.run(
          a_path => 'ut3_develop.test_dummy_coverage',
          a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
          a_source_files => ut3_develop.ut_varchar2_list( l_file_path ),
          a_test_files => ut3_develop.ut_varchar2_list( )
        )
      );
    --Assert
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure coverage_tmp_data_refresh is
    l_actual    clob;
    l_results   ut3_develop.ut_varchar2_list;
  begin
    --Arrange
    select *
    bulk collect into l_results
    from table(
      ut3_develop.ut.run(
          a_path => 'ut3_develop:coverage_testing',
          a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
          a_include_objects => ut3_develop.ut_varchar2_list( 'ut3_develop.dummy_coverage' )
      )
    );
    ut3_tester_helper.coverage_helper.cleanup_dummy_coverage();
    ut3_tester_helper.coverage_helper.drop_dummy_coverage_pkg();
    ut3_tester_helper.coverage_helper.create_dummy_coverage_test_1();

    --Act
    select *
    bulk collect into l_results
    from table(
      ut3_develop.ut.run(
          a_path => 'ut3_develop:coverage_testing',
          a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
          a_include_objects => ut3_develop.ut_varchar2_list( 'ut3_develop.dummy_coverage' )
      )
    );

    --Assert
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    ut.expect(l_actual).to_equal(to_clob('<?xml version="1.0"?>
<coverage version="1">
</coverage>'));
  end;

end;
/
