create or replace package body test_coveralls_reporter is

  procedure report_on_file is
    v_run_id    integer;
    l_results   ut3.ut_varchar2_list;
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected := '{"source_files":[
{ "name": "test/dummy_coverage.pkb",
"coverage": [null,null,null,1,0,null,1]}]}
 ';
    --Act
    select *
      bulk collect into l_results
      from table(
        ut3.ut.run(
          a_path => 'test_dummy_coverage',
          a_reporter=> ut3.ut_coveralls_reporter( ),
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
