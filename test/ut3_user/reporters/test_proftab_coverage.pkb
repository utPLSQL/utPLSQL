create or replace package body test_proftab_coverage is

  procedure create_dummy_coverage_test_1 is
  begin
    ut3_tester_helper.coverage_helper.create_dummy_coverage_test_1();
    ut3_tester_helper.coverage_helper.grant_exec_on_cov_1();
  end;

  procedure drop_dummy_coverage_test_1 is
  begin
    ut3_tester_helper.coverage_helper.drop_dummy_coverage_test_1();
  end;

  procedure coverage_for_object is
    l_expected  clob;
    l_actual    clob;
    l_results   ut3.ut_varchar2_list;
  begin
    --Arrange
    l_expected := '%<file path="ut3.dummy_coverage">%';
    --Act
    select *
      bulk collect into l_results
      from table(
        ut3.ut.run(
          a_path => 'ut3.test_dummy_coverage',
          a_reporter=> ut3.ut_coverage_sonar_reporter( ),
          a_include_objects => ut3.ut_varchar2_list( 'ut3.dummy_coverage' )
        )
      );
    --Assert
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure coverage_for_object_no_owner is
    l_expected  clob;
    l_actual    clob;
    l_results   ut3.ut_varchar2_list;
  begin
    --Arrange
    l_expected := '%<file path="ut3.dummy_coverage">%';
    --Act
    select *
      bulk collect into l_results
      from table(
        ut3.ut.run(
          a_path => 'ut3.test_dummy_coverage',
          a_reporter=> ut3.ut_coverage_sonar_reporter( ),
          a_include_objects => ut3.ut_varchar2_list( 'dummy_coverage' )
        )
      );
    --Assert
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure coverage_for_schema is
    l_expected  clob;
    l_actual    clob;
    l_results   ut3.ut_varchar2_list;
  begin
    --Arrange
    l_expected := '<file path="ut3.%">';
    l_expected := '%'||l_expected||'%'||l_expected||'%';
    --Act
    select *
      bulk collect into l_results
      from table(
        ut3.ut.run(
          a_path => 'ut3.test_dummy_coverage',
          a_reporter=> ut3.ut_coverage_sonar_reporter( ),
          a_coverage_schemes => ut3.ut_varchar2_list( 'ut3' )
        )
      );
    --Assert
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure coverage_for_file is
    l_expected  clob;
    l_actual    clob;
    l_results   ut3.ut_varchar2_list;
    l_file_path varchar2(100);
  begin
    --Arrange
    l_file_path := lower('test/ut3.dummy_coverage.pkb');
    l_expected := '%<file path="'||l_file_path||'">%';
    --Act
    select *
      bulk collect into l_results
      from table(
        ut3.ut.run(
          a_path => 'ut3.test_dummy_coverage',
          a_reporter=> ut3.ut_coverage_sonar_reporter( ),
          a_source_files => ut3.ut_varchar2_list( l_file_path ),
          a_test_files => ut3.ut_varchar2_list( )
        )
      );
    --Assert
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure coverage_tmp_data_refresh is
    l_actual    clob;
    l_results   ut3.ut_varchar2_list;
  begin
    --Arrange
    select *
    bulk collect into l_results
    from table(
      ut3.ut.run(
          a_path => 'ut3:coverage_testing',
          a_reporter=> ut3.ut_coverage_sonar_reporter( ),
          a_include_objects => ut3.ut_varchar2_list( 'ut3.dummy_coverage' )
      )
    );
    ut3_tester_helper.coverage_helper.cleanup_dummy_coverage(test_coverage.g_run_id);
    ut3_tester_helper.coverage_helper.drop_dummy_coverage_pkg();
    create_dummy_coverage_test_1;

    --Act
    select *
    bulk collect into l_results
    from table(
      ut3.ut.run(
          a_path => 'ut3:coverage_testing',
          a_reporter=> ut3.ut_coverage_sonar_reporter( ),
          a_include_objects => ut3.ut_varchar2_list( 'ut3.dummy_coverage' )
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
