create or replace package body test_junit_reporter as

  procedure create_a_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package check_junit_reporting is
      --%suite(A suite with <tag>)

      --%test(A test with <tag>)
      procedure test_do_stuff;
      
    end;]';
    execute immediate q'[create or replace package body check_junit_reporting is
      procedure test_do_stuff is
      begin
        ut3.ut.expect(1).to_equal(1);
        ut3.ut.expect(1).to_equal(2);
      end;

    end;]';
    
    execute immediate q'[create or replace package check_junit_rep_suitepath is
      --%suitepath(core)
      --%suite(check_junit_rep_suitepath)
      --%displayname(Check junit Get path for suitepath)
            
      --%test(check_junit_rep_suitepath)
      --%displayname(Check junit Get path for suitepath)
      procedure check_junit_rep_suitepath;
    end;]';
    execute immediate q'[create or replace package body check_junit_rep_suitepath is
      procedure check_junit_rep_suitepath is
      begin
        ut3.ut.expect(1).to_equal(1);
      end;
    end;]';
    
    
    execute immediate q'[create or replace package tst_package_junit_nodesc as
      --%suite(Suite name)

      --%test
      procedure test1;
  
     --%test(Test name)
     procedure test2;  
   end;]';

   execute immediate q'[create or replace package body tst_package_junit_nodesc as
    procedure test1 is begin ut.expect(1).to_equal(1); end;
    procedure test2 is begin ut.expect(1).to_equal(1); end;
  end;]';
   
    execute immediate q'[create or replace package tst_package_junit_nosuite as
      --%suite

      --%test(Test name)
      procedure test1;
   end;]';

   execute immediate q'[create or replace package body tst_package_junit_nosuite as
    procedure test1 is begin ut.expect(1).to_equal(1); end;
  end;]';

  reporters.reporters_setup;
  
  end;

  procedure escapes_special_chars is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3.ut.run('check_junit_reporting',ut3.ut_junit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).not_to_be_like('%<tag>%');
    ut.expect(l_actual).to_be_like('%&lt;tag&gt;%');
  end;

  procedure reports_only_failed_or_errored is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3.ut.run('check_junit_reporting',ut3.ut_junit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).not_to_be_like('%Actual: 1 (number) was expected to equal: 1 (number)%');
    ut.expect(l_actual).to_be_like('%Actual: 1 (number) was expected to equal: 2 (number)%');
  end;
  
  procedure reports_xunit_only_fail_or_err is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3.ut.run('check_junit_reporting',ut3.ut_xunit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).not_to_be_like('%Actual: 1 (number) was expected to equal: 1 (number)%');
    ut.expect(l_actual).to_be_like('%Actual: 1 (number) was expected to equal: 2 (number)%');
  end;
  
  procedure reports_failed_line is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3.ut.run('check_junit_reporting',ut3.ut_junit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('%at "%.CHECK_JUNIT_REPORTING%", line %');
  end;

  procedure check_classname_suite is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;    
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3.ut.run('check_junit_reporting',ut3.ut_junit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('%testcase classname="check_junit_reporting" assertions="%" name="%"%');
  end;

  procedure check_nls_number_formatting is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
    l_nls_numeric_characters varchar2(30);
  begin
    --Arrange
    select nsp.value into l_nls_numeric_characters
    from nls_session_parameters nsp
    where parameter = 'NLS_NUMERIC_CHARACTERS';
    execute immediate q'[alter session set NLS_NUMERIC_CHARACTERS=', ']';
    --Act
    select *
    bulk collect into l_results
    from table(ut3.ut.run('check_junit_reporting', ut3.ut_junit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_match('time="[0-9]*\.[0-9]{6}"');
    --Cleanup
    execute immediate 'alter session set NLS_NUMERIC_CHARACTERS='''||l_nls_numeric_characters||'''';
  end;

  procedure check_classname_suitepath is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;    
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3.ut.run('check_junit_rep_suitepath',ut3.ut_junit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('%testcase classname="core.check_junit_rep_suitepath" assertions="%" name="%"%');   
  end;
  
  procedure report_test_without_desc is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
    l_expected  varchar2(32767):= q'[<testsuites tests="2" disabled="0" errors="0" failures="0" name="" time="%" >
<testsuite tests="2" id="1" package="tst_package_junit_nodesc"  disabled="0" errors="0" failures="0" name="Suite name" time="%" >
<testcase classname="tst_package_junit_nodesc" assertions="0" name="test1" time="%" >
<system-out/>
<system-err/>
</testcase>
<testcase classname="tst_package_junit_nodesc" assertions="0" name="Test name" time="%" >
<system-out/>
<system-err/>
</testcase>
<system-out/>
<system-err/>
</testsuite>
</testsuites>]';
  begin
    select *
      bulk collect into l_results
    from table(ut3.ut.run('tst_package_junit_nodesc',ut3.ut_junit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);  
  end;
  
  procedure report_suite_without_desc is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
    l_expected  varchar2(32767):= q'[<testsuites tests="1" disabled="0" errors="0" failures="0" name="" time="%" >
<testsuite tests="1" id="1" package="tst_package_junit_nosuite"  disabled="0" errors="0" failures="0" name="tst_package_junit_nosuite" time="%" >
<testcase classname="tst_package_junit_nosuite" assertions="0" name="Test name" time="%" >
<system-out/>
<system-err/>
</testcase>
<system-out/>
<system-err/>
</testsuite>
</testsuites>]';
  begin
    select *
      bulk collect into l_results
    from table(ut3.ut.run('tst_package_junit_nosuite',ut3.ut_junit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);  
  end;
  
  procedure reporort_produces_expected_out is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
    l_expected  varchar2(32767):=q'[<testsuites tests="4" disabled="1" errors="1" failures="1" name="" time="%" >
<testsuite tests="4" id="1" package="utplsqlorg"  disabled="1" errors="1" failures="1" name="utplsqlorg" time="%" >
<testsuite tests="4" id="2" package="utplsqlorg.helpers"  disabled="1" errors="1" failures="1" name="helpers" time="%" >
<testsuite tests="4" id="3" package="utplsqlorg.helpers.tests"  disabled="1" errors="1" failures="1" name="tests" time="%" >
<testsuite tests="4" id="4" package="utplsqlorg.helpers.tests.test"  disabled="1" errors="1" failures="1" name="test" time="%" >
<testsuite tests="4" id="5" package="utplsqlorg.helpers.tests.test.test_reporters"  disabled="1" errors="1" failures="1" name="test_reporters" time="%" >
<testsuite tests="4" id="6" package="utplsqlorg.helpers.tests.test.test_reporters.test_reporters"  disabled="1" errors="1" failures="1" name="A suite for testing different outcomes from reporters" time="%" >
<testcase classname="utplsqlorg.helpers.tests.test.test_reporters.test_reporters" assertions="1" name="passing_test" time="%" >
<system-out>%
</system-out>
<system-err/>
</testcase>
<testcase classname="utplsqlorg.helpers.tests.test.test_reporters.test_reporters" assertions="1" name="a test with failing assertion" time="%"  status="Failure">
<failure>%Fails as values are different%
</failure>
<system-out>%
</system-out>
<system-err/>
</testcase>
<testcase classname="utplsqlorg.helpers.tests.test.test_reporters.test_reporters" assertions="0" name="a test raising unhandled exception" time="%"  status="Error">
<error>%ORA-06502:%
</error>
<system-out>%
</system-out>
<system-err/>
</testcase>
<testcase classname="utplsqlorg.helpers.tests.test.test_reporters.test_reporters" assertions="0" name="a disabled test" time="0"  status="Disabled">
<skipped/>
<system-out/>
<system-err/>
</testcase>
<system-out>%
</system-out>
<system-err/>
</testsuite>
</testsuite>
</testsuite>
</testsuite>
</testsuite>
</testsuite>
</testsuites>]';

  begin
    select *
      bulk collect into l_results
    from table(ut3.ut.run('test_reporters',ut3.ut_junit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);  
  end;
  
  procedure remove_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package check_junit_reporting';
    execute immediate 'drop package check_junit_rep_suitepath';
    execute immediate 'drop package tst_package_junit_nodesc';
    execute immediate 'drop package tst_package_junit_nosuite';
    reporters.reporters_cleanup;
  end;
end;
/
