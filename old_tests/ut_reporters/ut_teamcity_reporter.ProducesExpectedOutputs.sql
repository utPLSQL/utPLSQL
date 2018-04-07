declare
  l_output_data       ut_varchar2_list;
  l_output            clob;
  l_expected          varchar2(32767);
begin
  l_expected := q'{%##teamcity[testSuiteStarted timestamp='%' name='org']
%##teamcity[testSuiteStarted timestamp='%' name='org.utplsql']
%##teamcity[testSuiteStarted timestamp='%' name='org.utplsql.utplsql']
%##teamcity[testSuiteStarted timestamp='%' name='org.utplsql.utplsql.test']
%##teamcity[testSuiteStarted timestamp='%' name='A suite for testing different outcomes from reporters']
%##teamcity[testStarted timestamp='%' captureStandardOutput='true' name='ut3.test_reporters.passing_test']
<!beforeeach!>
<!beforetest!>
<!passing test!>
<!aftertest!>
<!aftereach!>
%##teamcity[testFinished timestamp='%' duration='%' name='ut3.test_reporters.passing_test']
%##teamcity[testStarted timestamp='%' captureStandardOutput='true' name='ut3.test_reporters.failing_test']
<!beforeeach!>
<!failing test!>
<!aftereach!>
%##teamcity[testFailed timestamp='%' message='Fails as values are different' name='ut3.test_reporters.failing_test']
%##teamcity[testFinished timestamp='%' duration='%' name='ut3.test_reporters.failing_test']
%##teamcity[testStarted timestamp='%' captureStandardOutput='true' name='ut3.test_reporters.erroring_test']
<!beforeeach!>
<!erroring test!>
<!aftereach!>
%##teamcity[testStdErr timestamp='%' name='ut3.test_reporters.erroring_test' out='Test exception:|rORA-06512: at |"UT3.TEST_REPORTERS|", line %|rORA-06512: at %|r|r']
%##teamcity[testFailed timestamp='%' details='Test exception:|rORA-06512: at |"UT3.TEST_REPORTERS|", line %|rORA-06512: at %|r|r' message='Error occured' name='ut3.test_reporters.erroring_test']
%##teamcity[testFinished timestamp='%' duration='%' name='ut3.test_reporters.erroring_test']
%##teamcity[testStarted timestamp='%' captureStandardOutput='true' name='ut3.test_reporters.disabled_test']
%##teamcity[testIgnored timestamp='%' name='ut3.test_reporters.disabled_test']
%##teamcity[testSuiteFinished timestamp='%' name='A suite for testing different outcomes from reporters']
%##teamcity[testSuiteFinished timestamp='%' name='org.utplsql.utplsql.test']
%##teamcity[testSuiteFinished timestamp='%' name='org.utplsql.utplsql']
%##teamcity[testSuiteFinished timestamp='%' name='org.utplsql']
%##teamcity[testSuiteFinished timestamp='%' name='org']}';
  --act
  select *
  bulk collect into l_output_data
  from table(ut.run('test_reporters',ut_teamcity_reporter()));

  l_output := ut_utils.table_to_clob(l_output_data);
  --assert
  if l_output like l_expected then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line(l_output);
  end if;

end;
/
