@@helpers/test_demo_package.pck

set linesize 32767
set serveroutput on size unlimited format truncated

declare
  l_results ut_varchar2_list;
  l_clob    clob;
begin
  select *
    bulk collect into l_results
    from table(ut.run('test_demo_package',ut_teamcity_reporter()));
  l_clob := ut_utils.table_to_clob(l_results);
  ut.expect(
    l_clob
  ).to_( be_like(
'##teamcity[testSuiteStarted timestamp=''%'' name=''test_demo_package'']' ||
'##teamcity[testStarted timestamp=''%'' captureStandardOutput=''true'' name=''ut3.test_demo_package.success_test'']' ||
'##teamcity[testFinished timestamp=''%'' duration=''%'' name=''ut3.test_demo_package.success_test'']' ||
'##teamcity[testStarted timestamp=''%'' captureStandardOutput=''true'' name=''ut3.test_demo_package.failing_test'']' ||
'##teamcity[testFailed timestamp=''%'' details=''Actual: |''0A|'' (blob) was expected to equal: |''0B|'' (blob) '' name=''ut3.test_demo_package.failing_test'']' ||
'##teamcity[testFinished timestamp=''%'' duration=''%'' name=''ut3.test_demo_package.failing_test'']' ||
'##teamcity[testStarted timestamp=''%'' captureStandardOutput=''true'' name=''ut3.test_demo_package.erroring_test'']' ||
'##teamcity[testStdErr timestamp=''%'' name=''ut3.test_demo_package.erroring_test'' out=''Test exception:|rORA-06512: at |"UT3.TEST_DEMO_PACKAGE|", line 15|rORA-06512: at line 6|r|r'']' ||
'##teamcity[testFailed timestamp=''%'' details=''Test exception:|rORA-06512: at |"UT3.TEST_DEMO_PACKAGE|", line 15|rORA-06512: at line 6|r|r'' message=''Error occured'' name=''ut3.test_demo_package.erroring_test'']' ||
'##teamcity[testFinished timestamp=''%'' duration=''%'' name=''ut3.test_demo_package.erroring_test'']' ||
'##teamcity[testStarted timestamp=''%'' captureStandardOutput=''true'' name=''ut3.test_demo_package.disabled_test'']' ||
'##teamcity[testIgnored timestamp=''%'' name=''ut3.test_demo_package.disabled_test'']' ||
'##teamcity[testSuiteFinished timestamp=''%'' name=''test_demo_package'']'
           ));
  if ut_expectation_processor.get_aggregate_asserts_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line(ut_expectation_processor.get_asserts_results()(1).message);
  end if;

end;
/

drop package test_demo_package;
