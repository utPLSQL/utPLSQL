create or replace package body test_proftab_coverage is

  procedure coverage_for_object is
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected := coverage_helper.substitute_covered_package('%<file path="ut3_develop.{p}">%');
    --Act
    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        coverage_helper.substitute_covered_package(
            q'[
              ut3_develop.ut.run(
                a_path => 'ut3_develop.test_dummy_coverage',
                a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
                a_include_objects => ut3_develop.ut_varchar2_list( 'ut3_develop.{p}' )
              )
            ]'
          )
        );
    --Assert
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure coverage_for_object_no_owner is
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected := coverage_helper.substitute_covered_package('%<file path="ut3_develop.{p}">%');
    --Act
    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        coverage_helper.substitute_covered_package(
          q'[
              ut3_develop.ut.run(
                a_path => 'ut3_develop.test_dummy_coverage',
                a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
                a_include_objects => ut3_develop.ut_varchar2_list( '{p}' )
              )
            ]'
          )
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
    l_file_path varchar2(250);
  begin
    --Arrange
    l_file_path := coverage_helper.substitute_covered_package('test/ut3_develop.{p}.pkb');
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

  procedure dup_object_name_coverage is
    l_actual clob;
    l_expected clob;
  begin
    l_expected := '%<file path="ut3_develop.duplicate_name"><lineToCover lineNumber="6" covered="false"/>';
    --Act
    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
      q'[
            ut3_develop.ut.run(
              a_path => 'ut3_develop.test_duplicate_name',
              a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
              a_include_objects => ut3_develop.ut_varchar2_list( 'ut3_develop.duplicate_name' )
            )
          ]'
      );
    --Assert
    --TODO - need to fix coverage reporting so that coverage is grouped by object type not only object name
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
            a_include_objects => ut3_develop.ut_varchar2_list( 'ut3_develop.{p}' )
          )
        );
        coverage_helper.drop_dummy_coverage();
        coverage_helper.create_dummy_coverage_1();

    --Act
        insert into test_results
        select *
        from table(
          ut3_develop.ut.run(
            a_path => 'ut3_develop:coverage_testing',
            a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
            a_include_objects => ut3_develop.ut_varchar2_list( 'ut3_develop.{p}' )
          )
        );
        commit;
      end;
      ]';

    l_actual := ut3_tester_helper.coverage_helper.run_code_as_job( coverage_helper.substitute_covered_package(l_test_code) );
    --Assert
    ut.expect(l_actual).to_equal(to_clob('<?xml version="1.0"?>
<coverage version="1">
</coverage>'));
  end;

  procedure report_zero_coverage is
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected :=
      q'[<?xml version="1.0"?>
<!DOCTYPE coverage SYSTEM "http://cobertura.sourceforge.net/xml/coverage-04.dtd">
<coverage line-rate="0" branch-rate="0.0" lines-covered="0" lines-valid="9" branches-covered="0" branches-valid="0" complexity="0" version="1" timestamp="%">
<sources>
<source>ut3_develop.{p}</source>
</sources>
<packages>
<package name="{P}" line-rate="0.0" branch-rate="0.0" complexity="0.0">
<class name="{P}" filename="ut3_develop.{p}" line-rate="0.0" branch-rate="0.0" complexity="0.0">
<lines>
<line number="1" hits="0" branch="false"/>
<line number="2" hits="0" branch="false"/>
<line number="3" hits="0" branch="false"/>
<line number="4" hits="0" branch="false"/>
<line number="5" hits="0" branch="false"/>
<line number="6" hits="0" branch="false"/>
<line number="7" hits="0" branch="false"/>
<line number="8" hits="0" branch="false"/>
<line number="9" hits="0" branch="false"/>
</lines>
</class>
</package>
</packages>
</coverage>]';

    --Act
    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        coverage_helper.substitute_covered_package(
            q'[
              ut3_develop.ut.run(
                'ut3_develop.test_dummy_coverage.zero_coverage',
                ut3_develop.ut_coverage_cobertura_reporter(),
                a_include_objects => ut3_develop.ut_varchar2_list('UT3_DEVELOP.{P}')
              )
            ]'
          )
        );
    --Assert
    ut.expect(l_actual).to_be_like(coverage_helper.substitute_covered_package(l_expected));
  end;

end;
/
