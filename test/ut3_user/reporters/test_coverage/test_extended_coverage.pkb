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

  procedure coverage_with_dbms_stats is
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected := '%<file path="package body ut3_develop.stats">' ||
      '%<lineToCover lineNumber="4" covered="true"/>%';
    --Act
    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              a_path => 'ut3_develop.test_stats',
              a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
              a_coverage_schemes => ut3_develop.ut_varchar2_list( 'ut3_develop' ),
              a_include_objects => ut3_develop.ut_varchar2_list('stats')
            )
          ]'
        );
    --Assert
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure coverage_regex_include_schema is
    l_expected_ut3   clob;
    l_expected_help  clob;  
    l_actual_ut3     clob;
    l_actual_help    clob;   
    l_actual_both    clob;      

  begin
    --Arrange
    l_expected_ut3 := '%<file path="package body ut3_develop.test_regex_dummy_cov_schema">' ||
      '%<lineToCover lineNumber="4" covered="true"/>%';
    l_expected_help := '%<file path="package body ut3_tester_helper.test_regex_dummy_cov_schema">' ||
      '%<lineToCover lineNumber="4" covered="true"/>%';            
    --Act
    l_actual_ut3 :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              a_paths => ut3_develop.ut_varchar2_list('ut3_develop.test_regex_dummy_cov_schema', 'ut3_tester_helper.test_regex_dummy_cov_schema'),
              a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
              a_include_schema_expr => '^ut3_develop'
            )
          ]'
        );
    /*
    l_actual_help :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              a_paths => ut3_develop.ut_varchar2_list('ut3_develop.test_regex_dummy_cov_schema', 'ut3_tester_helper.test_regex_dummy_cov_schema'),
              a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
              a_include_schema_expr => '^ut3_tester_helper'
            )
          ]'
        );  

    l_actual_both :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              a_paths => ut3_develop.ut_varchar2_list('ut3_develop.test_regex_dummy_cov_schema', 'ut3_tester_helper.test_regex_dummy_cov_schema'),
              a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
              a_include_schema_expr => '^ut3_tester_helper||^ut3_tester_helper'
            )
          ]'
        ); 
    */              
    --Assert
    ut.expect(l_actual_ut3).to_be_like(l_expected_ut3);
    ut.expect(l_actual_ut3).not_to_be_like(l_expected_help);
    --ut.expect(l_actual_help).to_be_like(l_expected_help);
    --ut.expect(l_actual_help).not_to_be_like(l_expected_ut3);
    --ut.expect(l_actual_both).to_be_like(l_expected_ut3);
    --ut.expect(l_actual_both).to_be_like(l_expected_help);    
  end;
 
  procedure coverage_regex_include_object is
  begin
    null;
  end;

  procedure coverage_regex_exclude_schema is
  begin
    null;
  end;

  procedure coverage_regex_exclude_object is
  begin
    null;
  end;

end;
/
