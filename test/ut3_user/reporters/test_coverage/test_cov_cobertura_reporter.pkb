create or replace package body test_cov_cobertura_reporter is

  procedure report_on_file is
    l_results   ut3.ut_varchar2_list;
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected := 
    q'[<?xml version="1.0"?>
<!DOCTYPE coverage SYSTEM "http://cobertura.sourceforge.net/xml/coverage-04.dtd">
<coverage line-rate="0" branch-rate="0.0" lines-covered="2" lines-valid="3" branches-covered="0" branches-valid="0" complexity="0" version="1" timestamp="%">
<sources>
<source>test/ut3.dummy_coverage.pkb</source>
</sources>
<packages>
<package name="DUMMY_COVERAGE" line-rate="0.0" branch-rate="0.0" complexity="0.0">
<class name="DUMMY_COVERAGE" filename="test/ut3.dummy_coverage.pkb" line-rate="0.0" branch-rate="0.0" complexity="0.0">
<lines>
<line number="4" hits="1" branch="false"/>
<line number="5" hits="0" branch="false"/>
<line number="7" hits="1" branch="false"/>
</lines>
</class>
</package>
</packages>
</coverage>]';
    --Act
    select *
      bulk collect into l_results
      from table(
        ut3.ut.run(
          a_path => 'ut3.test_dummy_coverage',
          a_reporter=> ut3.ut_coverage_cobertura_reporter( ),
          a_source_files => ut3.ut_varchar2_list( 'test/ut3.dummy_coverage.pkb' ),
          a_test_files => ut3.ut_varchar2_list( )
        )
      );
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure report_zero_coverage is
    l_results   ut3.ut_varchar2_list;
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected :=
    q'[<?xml version="1.0"?>
<!DOCTYPE coverage SYSTEM "http://cobertura.sourceforge.net/xml/coverage-04.dtd">
<coverage line-rate="0" branch-rate="0.0" lines-covered="0" lines-valid="15" branches-covered="0" branches-valid="0" complexity="0" version="1" timestamp="%">
<sources>
<source>ut3.dummy_coverage</source>
</sources>
<packages>
<package name="DUMMY_COVERAGE" line-rate="0.0" branch-rate="0.0" complexity="0.0">
<class name="DUMMY_COVERAGE" filename="ut3.dummy_coverage" line-rate="0.0" branch-rate="0.0" complexity="0.0">
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
<line number="10" hits="0" branch="false"/>
<line number="11" hits="0" branch="false"/>
<line number="12" hits="0" branch="false"/>
<line number="13" hits="0" branch="false"/>
<line number="14" hits="0" branch="false"/>
<line number="15" hits="0" branch="false"/>
</lines>
</class>
</package>
</packages>
</coverage>]';

    test_coverage.cleanup_dummy_coverage;
    --Act
    select *
      bulk collect into l_results
      from table(
        ut3.ut.run(
          a_path => 'ut3.test_dummy_coverage',
          a_reporter=> ut3.ut_coverage_cobertura_reporter( ),
          a_include_objects => ut3.ut_varchar2_list('UT3.DUMMY_COVERAGE')
        )
      );
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like(l_expected);
    --Cleanup
    test_coverage.setup_dummy_coverage;
  end;

end;
/
