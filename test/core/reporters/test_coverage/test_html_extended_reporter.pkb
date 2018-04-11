create or replace package body test_html_extended_reporter is

  procedure report_on_file is
    l_results   ut3.ut_varchar2_list;
    l_expected  varchar2(32767);
    l_actual    clob;
  begin
    --Arrange
    l_expected := '%<h3>UT3.DUMMY_COVERAGE</h3>%<b>4</b> relevant lines. <span class="green"><b>3</b> lines covered</span> (including <span class="yellow"><b>1</b> lines partially covered</span> ) and <span class="red"><b>1</b> lines missed%';
    
    select *
      bulk collect into l_results
      from table(
        ut3.ut.run(
          a_path => 'ut3.test_dummy_coverage',
          a_reporter=> ut3.ut_coverage_html_reporter(),
          a_coverage_type => 'extended',
          a_source_files => ut3.ut_varchar2_list( 'test/ut3.dummy_coverage.pkb' ),
          a_test_files => ut3.ut_varchar2_list( )
        )
      );
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like(l_expected);
  end;

end test_html_extended_reporter;
/
