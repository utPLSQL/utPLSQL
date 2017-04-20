@@helpers/test_demo_package.pck

set linesize 32767
set serveroutput on size unlimited format truncated

declare
  l_results ut_varchar2_list;
  l_clob    clob;
begin
  select *
    bulk collect into l_results
    from table(ut.run('TEST_DEMO_PACKAGE',ut_coverage_sonar_reporter(a_include_object_list=> ut_varchar2_list('TEST_DEMO_PACKAGE'))));
  l_clob := ut_utils.table_to_clob(l_results);
  ut.expect( l_clob ).to_( be_like('<coverage version="1">%</coverage>'));
  if ut_expectation_processor.get_aggregate_asserts_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line(ut_expectation_processor.get_asserts_results()(1).message);
  end if;

end;
/

drop package test_demo_package;
