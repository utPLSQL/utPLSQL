create or replace package body test_proftab_coverage is

  procedure coverage_for_object is
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected := '%<file path="ut3_develop.dummy_coverage">%';
    --Act
    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              a_path => 'ut3_develop.test_dummy_coverage',
              a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
              a_include_objects => ut3_develop.ut_varchar2_list( 'ut3_develop.dummy_coverage' )
            )
          ]'
        );
    --Assert
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure coverage_for_object_no_owner is
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected := '%<file path="ut3_develop.dummy_coverage">%';
    --Act
    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              a_path => 'ut3_develop.test_dummy_coverage',
              a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
              a_include_objects => ut3_develop.ut_varchar2_list( 'dummy_coverage' )
            )
          ]'
        );
    --Assert
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure coverage_for_schema is
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected := '<file path="ut3_develop.%">';
    l_expected := '%'||l_expected||'%'||l_expected||'%';
    --Act
    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              a_path => 'ut3_develop.test_dummy_coverage',
              a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
              a_coverage_schemes => ut3_develop.ut_varchar2_list( 'ut3_develop' )
            )
          ]'
        );
    --Assert
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure coverage_for_file is
    l_expected  clob;
    l_actual    clob;
    l_file_path varchar2(100);
  begin
    --Arrange
    l_file_path := 'test/ut3_develop.dummy_coverage.pkb';
    l_expected := '%<file path="'||l_file_path||'">%';
    --Act
    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              a_path => 'ut3_develop.test_dummy_coverage',
              a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
              a_source_files => ut3_develop.ut_varchar2_list( ']'||l_file_path||q'[' ),
              a_test_files => ut3_develop.ut_varchar2_list( )
            )
          ]'
        );
    --Assert
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure coverage_tmp_data_refresh is
    l_actual    clob;
    l_test_code varchar2(32767);
  begin
    l_test_code := q'[
      declare
        l_tmp_data ut3_develop.ut_varchar2_list;
      begin
    --Arrange
        select * bulk collect into l_tmp_data
        from table(
          ut3_develop.ut.run(
            a_path => 'ut3_develop:coverage_testing',
            a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
            a_include_objects => ut3_develop.ut_varchar2_list( 'ut3_develop.dummy_coverage' )
          )
        );
        coverage_helper.drop_dummy_coverage();
        coverage_helper.create_dummy_coverage_test_1();

    --Act
        insert into test_results
        select *
        from table(
          ut3_develop.ut.run(
            a_path => 'ut3_develop:coverage_testing',
            a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
            a_include_objects => ut3_develop.ut_varchar2_list( 'ut3_develop.dummy_coverage' )
          )
        );
        commit;
      end;
      ]';

    l_actual := ut3_tester_helper.coverage_helper.run_code_as_job( l_test_code );
    --Assert
    ut.expect(l_actual).to_equal(to_clob('<?xml version="1.0"?>
<coverage version="1">
</coverage>'));
  end;

end;
/
