create or replace package body test_junit_reporter as

  procedure crate_a_test_package is
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
  procedure remove_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package check_junit_reporting';
    execute immediate 'drop package check_junit_rep_suitepath';
  end;
end;
/
