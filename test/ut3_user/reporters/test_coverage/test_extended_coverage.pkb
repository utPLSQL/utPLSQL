create or replace package body test_extended_coverage is

  function get_block_coverage_line return clob is
  begin
    return
      case
        when ut3_tester_helper.coverage_helper.block_coverage_available then
          '%<lineToCover lineNumber="4" covered="true" branchesToCover="3" coveredBranches="2"/>'
        else
          '%<lineToCover lineNumber="4" covered="true"/>'
      end;
  end;
  procedure coverage_for_object is
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected := '%<file path="package body ut3_develop.'||ut3_tester_helper.coverage_helper.covered_package_name||'">' ||
      get_block_coverage_line||
      '%<lineToCover lineNumber="6" covered="false"/>%';
    --Act
    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              a_path => 'ut3_develop.test_dummy_coverage',
              a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
              a_include_objects => ut3_develop.ut_varchar2_list( 'ut3_develop.]'||ut3_tester_helper.coverage_helper.covered_package_name||q'[' )
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
    l_expected := '%<file path="package body ut3_develop.'||ut3_tester_helper.coverage_helper.covered_package_name||'">' ||
      get_block_coverage_line ||
      '%<lineToCover lineNumber="6" covered="false"/>%';
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
    ut.expect(l_actual).to_be_like('%<file path="package body ut3_develop.%">%<file path="package body ut3_develop.%">%');
  end;

  procedure coverage_for_file is
    l_expected  clob;
    l_actual    clob;
    l_file_path varchar2(250);
  begin
    --Arrange
    l_file_path := 'test/ut3_develop.'||ut3_tester_helper.coverage_helper.covered_package_name||'.pkb';
    l_expected := '%<file path="'||l_file_path||'">' ||
      get_block_coverage_line ||
      '%<lineToCover lineNumber="6" covered="false"/>%';
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

end;
/
