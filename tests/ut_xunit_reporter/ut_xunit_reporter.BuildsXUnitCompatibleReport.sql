@@helpers/test_demo_package.pck

set linesize 32767
set serveroutput on size unlimited format truncated

declare
  l_results ut_varchar2_list;
  l_clob    clob;
begin
  select *
    bulk collect into l_results
    from table(ut.run('test_demo_package',ut_xunit_reporter()));
  l_clob := ut_utils.table_to_clob(l_results);
  ut.expect(
    l_clob
  ).to_( be_like(
'<testsuites tests="4" skipped="1" error="1" failure="1" name="" time="%" >' ||
    '<testsuite tests="4" id="1" package="test_demo_package"  skipped="1" error="1" failure="1" name="" time="%" >%' ||
        '<testcase classname="test_demo_package"  assertions="1" skipped="0" error="0" failure="0" name="A passing test" time="%" ></testcase>' ||
        '<testcase classname="test_demo_package"  assertions="1" skipped="0" error="0" failure="1" name="A failing test" time="%"  status="Failure">' ||
            '<failure><![CDATA[Actual: ''0A'' (blob) was expected to equal: ''0B'' (blob) ]]></failure></testcase>' ||
        '<testcase classname="test_demo_package"  assertions="0" skipped="0" error="1" failure="0" name="A test raising exception" time="%"  status="Error">' ||
            '<error><![CDATA[ORA-01476%]]></error>' ||
        '</testcase>' ||
        '<testcase classname="test_demo_package"  assertions="0" skipped="1" error="0" failure="0" name="A disabled test" time="0"  status="Disabled">' ||
            '<skipped/>' ||
        '</testcase>' ||
    '</testsuite>' ||
'</testsuites>'));

  if ut_expectation_processor.get_aggregate_asserts_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line(ut_expectation_processor.get_asserts_results()(1).message);
  end if;

end;
/

drop package test_demo_package;
