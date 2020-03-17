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
        ut3_develop.ut.expect(1).to_equal(1);
        ut3_develop.ut.expect(1).to_equal(2);
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
        ut3_develop.ut.expect(1).to_equal(1);
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
  
  execute immediate q'[create or replace package Tst_Fix_Case_Sensitive as
      --%suite

      --%test(bugfix)
      procedure bUgFiX;
  end;]';

   execute immediate q'[create or replace package body Tst_Fix_Case_Sensitive as
    procedure bUgFiX is begin ut.expect(1).to_equal(1); end;
  end;]';  

  end;

  procedure escapes_special_chars is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3_develop.ut.run('check_junit_reporting',ut3_develop.ut_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).not_to_be_like('%<tag>%');
    ut.expect(l_actual).to_be_like('%&lt;tag&gt;%');
  end;

  procedure reports_only_failed_or_errored is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3_develop.ut.run('check_junit_reporting',ut3_develop.ut_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).not_to_be_like('%Actual: 1 (number) was expected to equal: 1 (number)%');
    ut.expect(l_actual).to_be_like('%Actual: 1 (number) was expected to equal: 2 (number)%');
  end;
  
  procedure reports_xunit_only_fail_or_err is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3_develop.ut.run('check_junit_reporting',ut3_develop.ut_xunit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).not_to_be_like('%Actual: 1 (number) was expected to equal: 1 (number)%');
    ut.expect(l_actual).to_be_like('%Actual: 1 (number) was expected to equal: 2 (number)%');
  end;
  
  procedure check_classname_suite is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;    
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3_develop.ut.run('check_junit_reporting',ut3_develop.ut_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('%testcase classname="check_junit_reporting" assertions="%" name="%"%');
  end;

  procedure check_nls_number_formatting is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;
    l_nls_numeric_characters varchar2(30);
  begin
    --Arrange
    select replace(nsp.value,'''','''''') into l_nls_numeric_characters
    from nls_session_parameters nsp
    where parameter = 'NLS_NUMERIC_CHARACTERS';
    execute immediate q'[alter session set NLS_NUMERIC_CHARACTERS=', ']';
    --Act
    select *
    bulk collect into l_results
    from table(ut3_develop.ut.run('check_junit_reporting', ut3_develop.ut_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_match('time="[0-9]*\.[0-9]{3,6}"');
    --Cleanup
    execute immediate 'alter session set NLS_NUMERIC_CHARACTERS='''||l_nls_numeric_characters||'''';
  end;

  procedure check_classname_suitepath is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;    
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3_develop.ut.run('check_junit_rep_suitepath',ut3_develop.ut_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('%testcase classname="core.check_junit_rep_suitepath" assertions="%" name="%"%');   
  end;
  
  procedure report_test_without_desc is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;
    l_expected  varchar2(32767):= q'[<?xml version="1.0"?>
<testsuites tests="2" disabled="0" errors="0" failures="0" name="" time="%" >
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
    from table(ut3_develop.ut.run('tst_package_junit_nodesc',ut3_develop.ut_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);  
  end;
  
  procedure report_suite_without_desc is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;
    l_expected  varchar2(32767):= q'[<?xml version="1.0"?>
<testsuites tests="1" disabled="0" errors="0" failures="0" name="" time="%" >
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
    from table(ut3_develop.ut.run('tst_package_junit_nosuite',ut3_develop.ut_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);  
  end;
  
  procedure reporort_produces_expected_out is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;
    l_expected  varchar2(32767):=q'[<?xml version="1.0"?>
<testsuites tests="4" disabled="1" errors="1" failures="1" name="" time="%" >
<testsuite tests="4" id="1" package="org"  disabled="1" errors="1" failures="1" name="org" time="%" >
<testsuite tests="4" id="2" package="org.utplsql"  disabled="1" errors="1" failures="1" name="utplsql" time="%" >
<testsuite tests="4" id="3" package="org.utplsql.tests"  disabled="1" errors="1" failures="1" name="tests" time="%" >
<testsuite tests="4" id="4" package="org.utplsql.tests.helpers"  disabled="1" errors="1" failures="1" name="helpers" time="%" >
<testsuite tests="4" id="5" package="org.utplsql.tests.helpers.test_reporters"  disabled="1" errors="1" failures="1" name="A suite for testing different outcomes from reporters" time="%" >
<testsuite tests="1" id="6" package="org.utplsql.tests.helpers.test_reporters.some_context"  disabled="0" errors="0" failures="0" name="A description of some context" time="%" >
<testcase classname="org.utplsql.tests.helpers.test_reporters.some_context" assertions="1" name="passing_test" time="%" >
<system-out>%
</system-out>
<system-err/>
</testcase>
<system-out/>
<system-err/>
</testsuite>
<testcase classname="org.utplsql.tests.helpers.test_reporters" assertions="1" name="a test with failing assertion" time="%"  status="Failure">
<failure>%Fails as values are different%
</failure>
<system-out>%
</system-out>
<system-err/>
</testcase>
<testcase classname="org.utplsql.tests.helpers.test_reporters" assertions="0" name="a test raising unhandled exception" time="%"  status="Error">
<error>%ORA-06502:%
</error>
<system-out>%
</system-out>
<system-err/>
</testcase>
<testcase classname="org.utplsql.tests.helpers.test_reporters" assertions="0" name="a disabled test" time="0"  status="Disabled">
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
</testsuites>]';

  begin
    select *
      bulk collect into l_results
    from table(ut3_develop.ut.run('test_reporters',ut3_develop.ut_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);  
  end;
  
  procedure check_failure_escaped is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;
  begin
    reporters.check_xml_failure_escaped(ut3_develop.ut_junit_reporter());
  end;
  
  procedure check_classname_is_populated is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;
    l_expected  varchar2(32767):= q'[<?xml version="1.0"?>
<testsuites tests="1" disabled="0" errors="0" failures="0" name="" time="%" >
<testsuite tests="1" id="1" package="tst_fix_case_sensitive"  disabled="0" errors="0" failures="0" name="tst_fix_case_sensitive" time="%" >
<testcase classname="tst_fix_case_sensitive" assertions="0" name="bugfix" time="%" >
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
    from table(ut3_develop.ut.run('Tst_Fix_Case_Sensitive',ut3_develop.ut_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);  
  end;

  procedure check_encoding_included is
  begin
    reporters.check_xml_encoding_included(ut3_develop.ut_junit_reporter(), 'UTF-8');
  end;

  procedure remove_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package check_junit_reporting';
    execute immediate 'drop package check_junit_rep_suitepath';
    execute immediate 'drop package tst_package_junit_nodesc';
    execute immediate 'drop package tst_package_junit_nosuite';
    execute immediate 'drop package Tst_Fix_Case_Sensitive';
  end;

end;
/
