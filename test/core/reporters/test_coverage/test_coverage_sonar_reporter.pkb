create or replace package body test_coverage_sonar_reporter is

  procedure report_on_file is
    l_results   ut3.ut_varchar2_list;
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected := '<?xml version="1.0"?>
<coverage version="1">
<file path="test/ut3.dummy_coverage.pkb">
<lineToCover lineNumber="4" covered="true"/>
<lineToCover lineNumber="5" covered="false"/>
<lineToCover lineNumber="7" covered="true"/>
</file>
</coverage>';
    --Act
    select *
      bulk collect into l_results
      from table(
        ut3.ut.run(
          a_path => 'ut3.test_dummy_coverage',
          a_reporter=> ut3.ut_coverage_sonar_reporter( ),
          a_source_files => ut3.ut_varchar2_list( 'test/ut3.dummy_coverage.pkb' ),
          a_test_files => ut3.ut_varchar2_list( )
        )
      );
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_equal(l_expected);
  end;

  procedure check_encoding_included is
  begin
    reporters.check_xml_encoding_included('ut3.test_dummy_coverage', ut3.ut_coverage_sonar_reporter(), 'UTF-8');
  end;

end;
/
