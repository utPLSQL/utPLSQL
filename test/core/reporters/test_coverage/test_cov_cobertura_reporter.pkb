create or replace package body test_cov_cobertura_reporter is

  procedure report_on_file is
    l_results   ut3.ut_varchar2_list;
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected := 
    '<?xml version="1.0"?>
<!DOCTYPE coverage SYSTEM "http://cobertura.sourceforge.net/xml/coverage-04.dtd">
<coverage line-rate="0" branch-rate="0.0" lines-covered="2" lines-valid="3" branches-covered="0" branches-valid="0" complexity="0" version="1" timestamp="%"><sources>
<source>test/ut3.dummy_coverage.pkb</source>
</sources>
<packages>
<package name="test/ut3.dummy_coverage.pkb" line-rate="0.0" branch-rate="0.0" complexity="0.0">
<class name="ut3.dummy_coverage" filename="test/ut3.dummy_coverage.pkb" line-rate="0.0" branch-rate="0.0" complexity="0.0">
<lines>
<line number="4" hits="1" branch="false"/>
<line number="5" hits="0" branch="false"/>
<line number="7" hits="1" branch="false"/>
</lines>
</class>
</package>
</packages>
</coverage>';
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
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like(l_expected);
  end;

end;
/
