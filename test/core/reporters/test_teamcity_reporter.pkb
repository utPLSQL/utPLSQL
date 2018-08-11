create or replace package body test_teamcity_reporter as

  procedure report_produces_expected_out is
    l_output_data       ut3.ut_varchar2_list;
    l_output            clob;
    l_expected          varchar2(32767);
  begin
    l_expected := q'{%##teamcity[testSuiteStarted timestamp='%' name='org']
%##teamcity[testSuiteStarted timestamp='%' name='org.utplsql']
%##teamcity[testSuiteStarted timestamp='%' name='org.utplsql.tests']
%##teamcity[testSuiteStarted timestamp='%' name='org.utplsql.tests.helpers']
%##teamcity[testSuiteStarted timestamp='%' name='A suite for testing different outcomes from reporters']
%##teamcity[testSuiteStarted timestamp='%' name='A description of some context']
%##teamcity[testStarted timestamp='%' captureStandardOutput='true' name='ut3_tester.test_reporters.passing_test']
<!beforeeach!>
<!beforetest!>
<!passing test!>
<!aftertest!>
<!aftereach!>
%##teamcity[testFinished timestamp='%' duration='%' name='ut3_tester.test_reporters.passing_test']
%##teamcity[testSuiteFinished timestamp='%' name='A description of some context']
%##teamcity[testStarted timestamp='%' captureStandardOutput='true' name='ut3_tester.test_reporters.failing_test']
<!beforeeach!>
<!failing test!>
<!aftereach!>
%##teamcity[testFailed timestamp='%' message='Fails as values are different' name='ut3_tester.test_reporters.failing_test']
%##teamcity[testFinished timestamp='%' duration='%' name='ut3_tester.test_reporters.failing_test']
%##teamcity[testStarted timestamp='%' captureStandardOutput='true' name='ut3_tester.test_reporters.erroring_test']
<!beforeeach!>
<!erroring test!>
<!aftereach!>
%##teamcity[testStdErr timestamp='%' name='ut3_tester.test_reporters.erroring_test' out='Test exception:|rORA-06512: at |"UT3_TESTER.TEST_REPORTERS|", line %|rORA-06512: at %|r|r']
%##teamcity[testFailed timestamp='%' details='Test exception:|rORA-06512: at |"UT3_TESTER.TEST_REPORTERS|", line %|rORA-06512: at %|r|r' message='Error occured' name='ut3_tester.test_reporters.erroring_test']
%##teamcity[testFinished timestamp='%' duration='%' name='ut3_tester.test_reporters.erroring_test']
%##teamcity[testStarted timestamp='%' captureStandardOutput='true' name='ut3_tester.test_reporters.disabled_test']
%##teamcity[testIgnored timestamp='%' name='ut3_tester.test_reporters.disabled_test']
%##teamcity[testSuiteFinished timestamp='%' name='A suite for testing different outcomes from reporters']
%##teamcity[testSuiteFinished timestamp='%' name='org.utplsql.tests.helpers']
%##teamcity[testSuiteFinished timestamp='%' name='org.utplsql.tests']
%##teamcity[testSuiteFinished timestamp='%' name='org.utplsql']
%##teamcity[testSuiteFinished timestamp='%' name='org']}';
    --act
    select *
    bulk collect into l_output_data
    from table(ut3.ut.run('test_reporters',ut3.ut_teamcity_reporter()));

    --assert
    ut.expect(ut3.ut_utils.table_to_clob(l_output_data)).to_be_like(l_expected);
  end;

end;
/
