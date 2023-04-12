create or replace package body test_teamcity_reporter as

  procedure create_a_test_package is
    pragma autonomous_transaction;
    begin
      execute immediate q'[create or replace package check_escape_special_chars is
      --%suite(A suite with 'quote')

      --%test(A test with 'quote')
      procedure test_do_stuff;

    end;]';
      execute immediate q'[create or replace package body check_escape_special_chars is
      procedure test_do_stuff is
      begin
        ut3_develop.ut.expect(' [ ' || chr(13) || chr(10) || ' ] ' ).to_be_null;
      end;

    end;]';

      execute immediate q'[create or replace package check_trims_long_output is
      --%suite

      --%test
      procedure long_output;
    end;]';
      execute immediate q'[create or replace package body check_trims_long_output is
      procedure long_output is
      begin
        ut3_develop.ut.expect(rpad('aVarchar',4000,'a')).to_be_null;
      end;
    end;]';

      execute immediate q'[create or replace package check_multiple_failures is
      --%suite

      --%test
      procedure multi_failure;
    end;]';
      execute immediate q'[create or replace package body check_multiple_failures is
      procedure multi_failure is
      begin
        ut3_develop.ut.expect(1).to_be_null;
        ut3_develop.ut.expect(2).to_equal(1);
        ut3_develop.ut.expect('Bad').to_equal('Good');
      end;
    end;]';

    end;


  procedure report_produces_expected_out is
    l_output_data       ut3_develop.ut_varchar2_list;
    l_expected          varchar2(32767);
  begin
    l_expected := q'{%##teamcity[testSuiteStarted timestamp='%' name='org']
%##teamcity[testSuiteStarted timestamp='%' name='org.utplsql']
%##teamcity[testSuiteStarted timestamp='%' name='org.utplsql.tests']
%##teamcity[testSuiteStarted timestamp='%' name='org.utplsql.tests.helpers']
%##teamcity[testSuiteStarted timestamp='%' name='A suite for testing different outcomes from reporters']
%##teamcity[testSuiteStarted timestamp='%' name='A description of some context']
%##teamcity[testStarted timestamp='%' captureStandardOutput='true' name='ut3_user.test_reporters.passing_test']
<!beforeeach!>
<!beforetest!>
<!passing test!>
<!aftertest!>
<!aftereach!>
%##teamcity[testFinished timestamp='%' duration='%' name='ut3_user.test_reporters.passing_test']
%##teamcity[testSuiteFinished timestamp='%' name='A description of some context']
%##teamcity[testStarted timestamp='%' captureStandardOutput='true' name='ut3_user.test_reporters.failing_test']
<!beforeeach!>
<!failing test!>
<!aftereach!>
%##teamcity[testFailed timestamp='%' details='Actual: |'number |[1|] |' (varchar2) was expected to equal: |'number |[2|] |' (varchar2)' message='Fails as values are different' name='ut3_user.test_reporters.failing_test']
%##teamcity[testFinished timestamp='%' duration='%' name='ut3_user.test_reporters.failing_test']
%##teamcity[testStarted timestamp='%' captureStandardOutput='true' name='ut3_user.test_reporters.erroring_test']
<!beforeeach!>
<!erroring test!>
<!aftereach!>
%##teamcity[testStdErr timestamp='%' name='ut3_user.test_reporters.erroring_test' out='Test exception:|nORA-06502: PL/SQL: %: character to number conversion error|nORA-06512: at "UT3_USER.TEST_REPORTERS", line %|nORA-06512: at %|n']
%##teamcity[testFailed timestamp='%' details='Test exception:|nORA-06502: PL/SQL: %: character to number conversion error|nORA-06512: at "UT3_USER.TEST_REPORTERS", line %|nORA-06512: at %|n' message='Error occured' name='ut3_user.test_reporters.erroring_test']
%##teamcity[testFinished timestamp='%' duration='%' name='ut3_user.test_reporters.erroring_test']
%##teamcity[testStarted timestamp='%' captureStandardOutput='true' name='ut3_user.test_reporters.disabled_test']
%##teamcity[testIgnored timestamp='%' name='ut3_user.test_reporters.disabled_test']
%##teamcity[testSuiteFinished timestamp='%' name='A suite for testing different outcomes from reporters']
%##teamcity[testSuiteFinished timestamp='%' name='org.utplsql.tests.helpers']
%##teamcity[testSuiteFinished timestamp='%' name='org.utplsql.tests']
%##teamcity[testSuiteFinished timestamp='%' name='org.utplsql']
%##teamcity[testSuiteFinished timestamp='%' name='org']}';
    --act
    select *
    bulk collect into l_output_data
    from table(ut3_develop.ut.run('test_reporters',ut3_develop.ut_teamcity_reporter()));

    --assert
    ut.expect(ut3_tester_helper.main_helper.table_to_clob(l_output_data)).to_be_like(l_expected);
  end;

  procedure escape_special_chars is
    l_output_data       ut3_develop.ut_varchar2_list;
    l_expected          varchar2(32767);
  begin
    l_expected := q'{%##teamcity[testSuiteStarted timestamp='%' name='A suite with |'quote|'']
%##teamcity[testStarted timestamp='%' captureStandardOutput='true' name='ut3_user.check_escape_special_chars.test_do_stuff']
%##teamcity[testFailed timestamp='%' details='Actual: (varchar2)|n    |' |[ |r|n     |] |'|n was expected to be null' name='ut3_user.check_escape_special_chars.test_do_stuff']
%##teamcity[testFinished timestamp='%' duration='%' name='ut3_user.check_escape_special_chars.test_do_stuff']
%##teamcity[testSuiteFinished timestamp='%' name='A suite with |'quote|'']}';
    --act
    select *
        bulk collect into l_output_data
    from table(ut3_develop.ut.run('check_escape_special_chars',ut3_develop.ut_teamcity_reporter()));

    --assert
    ut.expect(ut3_tester_helper.main_helper.table_to_clob(l_output_data)).to_be_like(l_expected);
  end;

  procedure trims_long_output is
    l_output_data       ut3_develop.ut_varchar2_list;
    l_expected          varchar2(32767);
  begin
    l_expected := q'{%##teamcity[testSuiteStarted timestamp='%' name='check_trims_long_output']
%##teamcity[testStarted timestamp='%' captureStandardOutput='true' name='ut3_user.check_trims_long_output.long_output']
%##teamcity[testFailed timestamp='%' details='Actual: (varchar2)|n    |'aVarcharaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa|[...|]' name='ut3_user.check_trims_long_output.long_output']
%##teamcity[testFinished timestamp='%' duration='%' name='ut3_user.check_trims_long_output.long_output']
%##teamcity[testSuiteFinished timestamp='%' name='check_trims_long_output']}';
    --act
    select *
        bulk collect into l_output_data
    from table(ut3_develop.ut.run('check_trims_long_output',ut3_develop.ut_teamcity_reporter()));

    --assert
    ut.expect(ut3_tester_helper.main_helper.table_to_clob(l_output_data)).to_be_like(l_expected);
  end;

  procedure report_mutiple_expectations is
    l_output_data       ut3_develop.ut_varchar2_list;
    l_expected          varchar2(32767);
  begin
    l_expected := q'{%##teamcity[testSuiteStarted timestamp='%' name='check_multiple_failures']
%##teamcity[testStarted timestamp='%' captureStandardOutput='true' name='ut3_user.check_multiple_failures.multi_failure']
%##teamcity[testFailed timestamp='%' details='Actual: 1 (number) was expected to be null' name='ut3_user.check_multiple_failures.multi_failure']
%##teamcity[testFailed timestamp='%' details='Actual: 2 (number) was expected to equal: 1 (number)' name='ut3_user.check_multiple_failures.multi_failure']
%##teamcity[testFailed timestamp='%' details='Actual: |'Bad|' (varchar2) was expected to equal: |'Good|' (varchar2)' name='ut3_user.check_multiple_failures.multi_failure']
%##teamcity[testFinished timestamp='%' duration='%' name='ut3_user.check_multiple_failures.multi_failure']
%##teamcity[testSuiteFinished timestamp='%' name='check_multiple_failures']}';
    --act
    select *
        bulk collect into l_output_data
    from table(ut3_develop.ut.run('check_multiple_failures',ut3_develop.ut_teamcity_reporter()));

    --assert
    ut.expect(ut3_tester_helper.main_helper.table_to_clob(l_output_data)).to_be_like(l_expected);
  end;

  procedure remove_test_package is
    pragma autonomous_transaction;
    begin
      execute immediate 'drop package check_escape_special_chars';
      execute immediate 'drop package check_trims_long_output';
      execute immediate 'drop package check_multiple_failures';
    end;

end;
/
