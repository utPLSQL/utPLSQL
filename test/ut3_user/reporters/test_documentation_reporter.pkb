create or replace package body test_documentation_reporter as

  procedure report_produces_expected_out is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;
    l_expected  varchar2(32767):=q'[%org
  utplsql
    tests
      helpers
        A suite for testing different outcomes from reporters
          <!beforeall!>
          A description of some context
            passing_test [% sec]
            <!beforeeach!>
            <!beforetest!>
            <!passing test!>
            <!aftertest!>
            <!aftereach!>
          a test with failing assertion [% sec] (FAILED - 1)
          <!beforeeach!>
          <!failing test!>
          <!aftereach!>
          a test raising unhandled exception [% sec] (FAILED - 2)
          <!beforeeach!>
          <!erroring test!>
          <!aftereach!>
          a disabled test [0 sec] (DISABLED - Disabled for testing purpose)
          <!afterall!>
%
Failures:
%
  1) failing_test
      "Fails as values are different"
      Actual: 'number [1] ' (varchar2) was expected to equal: 'number [2] ' (varchar2)%
      at "UT3$USER#.TEST_REPORTERS%", line 36 ut3_develop.ut.expect('number [1] ','Fails as values are different').to_equal('number [2] ');
%
%
  2) erroring_test
      ORA-06502: PL/SQL: numeric or value error: character to number conversion error
      ORA-06512: at "UT3$USER#.TEST_REPORTERS", line 44%
      ORA-06512: at line 6
Finished in % seconds
4 tests, 1 failed, 1 errored, 1 disabled, 0 warning(s)%]';

  begin
    select *
    bulk collect into l_results
    from table(
      ut3_develop.ut.run(
          'test_reporters',
          ut3_develop.ut_documentation_reporter()
      )
    );
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);  
  end;

end;
/
