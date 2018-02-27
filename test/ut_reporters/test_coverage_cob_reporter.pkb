create or replace package body test_coverage_cob_reporter is

  procedure report_on_file is
    l_results   ut3.ut_varchar2_list;
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected := 
    '<?xml version="1.0"?>
<!DOCTYPE coverage SYSTEM "http://cobertura.sourceforge.net/xml/coverage-04.dtd">
<coverage line-rate="0" branch-rate="0.0" lines-covered="2" lines-valid="3" branches-covered="0" branches-valid="0" complexity="0" version="1" timestamp="1403301904999"><sources>
<source>test/dummy_coverage.pkb</source>
</sources>
<packages>
<package name="test/dummy_coverage.pkb" line-rate="0.0" branch-rate="0.0" complexity="0.0">
<class name="test/dummy_coverage.pkb" filename="test/dummy_coverage.pkb" line-rate="0.0" branch-rate="0.0" complexity="0.0">
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
          a_path => 'test_dummy_coverage',
          a_reporter=> ut3.ut_coverage_cob_reporter( ),
          a_source_files => ut3.ut_varchar2_list( 'test/dummy_coverage.pkb' ),
          a_test_files => ut3.ut_varchar2_list( )
        )
      );
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_equal(l_expected);
  end;

end;
/
