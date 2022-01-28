create or replace package body test_cov_cobertura_reporter is

  procedure report_on_file is
    l_expected  clob;
    l_actual    clob;
    l_block_cov clob;
    l_name      varchar2(250);
    l_file_path varchar2(250);
  begin


    --Arrange
    l_name := ut3_tester_helper.coverage_helper.covered_package_name;
    l_file_path := 'test/ut3_develop.'||ut3_tester_helper.coverage_helper.covered_package_name||'.pkb';
    if ut3_tester_helper.coverage_helper.block_coverage_available then
      l_block_cov := '<line number="4" hits="3" branch="true" condition-coverage="67% (2/3)"/>';
    else
      l_block_cov := '<line number="4" hits="3" branch="false"/>';
    end if;
    l_expected :=
    q'[<?xml version="1.0"?>
<!DOCTYPE coverage SYSTEM "http://cobertura.sourceforge.net/xml/coverage-04.dtd">
<coverage line-rate="0.5" branch-rate="0.0" lines-covered="1" lines-valid="2" branches-covered="0" branches-valid="0" complexity="0" version="1" timestamp="%">
<sources>
<source>]'||l_file_path||q'[</source>
</sources>
<packages>
<package name="]'||upper(l_name)||q'[" line-rate="0.0" branch-rate="0.0" complexity="0.0">
<classes>
<class name="]'||upper(l_name)||q'[" filename="]'||l_file_path||q'[" line-rate="0.0" branch-rate="0.0" complexity="0.0">
<lines>
]'||l_block_cov||q'[
<line number="6" hits="0" branch="false"/>
</lines>
</class>
</classes>
</package>
</packages>
</coverage>]';
    --Act
    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              a_path => 'ut3_develop.test_dummy_coverage',
              a_reporter => ut3_develop.ut_coverage_cobertura_reporter( ),
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
