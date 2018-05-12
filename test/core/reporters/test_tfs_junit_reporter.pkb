create or replace package body test_tfs_junit_reporter as

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
      --%displayname(Check JUNIT Get path for suitepath)
            
      --%test(check_junit_rep_suitepath)
      --%displayname(Check JUNIT Get path for suitepath)
      procedure check_junit_rep_suitepath;
    end;]';
    execute immediate q'[create or replace package body check_junit_rep_suitepath is
      procedure check_junit_rep_suitepath is
      begin
        ut3.ut.expect(1).to_equal(1);
      end;
    end;]';

  execute immediate q'[create or replace package check_junit_flat_suitepath is
      --%suitepath(core.check_junit_rep_suitepath)
      --%suite(flatsuitepath)
      
      --%beforeall
      procedure donuffin;
    end;]';
    execute immediate q'[create or replace package body check_junit_flat_suitepath is
      procedure donuffin is
      begin
        null;
      end;
    end;]';
    

  execute immediate q'[create or replace package check_fail_escape is
      --%suitepath(core)
      --%suite(checkfailedescape)
      --%displayname(Check JUNIT XML failure is escaped)
            
      --%test(Fail Miserably)
      procedure fail_miserably;
      
    end;]';
    
    execute immediate q'[create or replace package body check_fail_escape is
      procedure fail_miserably is
      begin
        ut3.ut.expect('test').to_equal('<![CDATA[some stuff]]>');
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
      from table(ut3.ut.run('check_junit_reporting',ut3.ut_tfs_junit_reporter()));
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
      from table(ut3.ut.run('check_junit_reporting',ut3.ut_tfs_junit_reporter()));
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
      from table(ut3.ut.run('check_junit_reporting',ut3.ut_tfs_junit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('%at &quot;%.CHECK_JUNIT_REPORTING%&quot;, line %');
  end;

  procedure check_classname_suite is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;    
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3.ut.run('check_junit_reporting',ut3.ut_tfs_junit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('%testcase classname="check_junit_reporting"%');
  end;
 
 procedure check_flatten_nested_suites is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;    
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3.ut.run('check_junit_flat_suitepath',ut3.ut_tfs_junit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('<testsuites>
<testsuite tests="0" id="1" package="core.check_junit_rep_suitepath.check_junit_flat_suitepath"  errors="0" failures="0" name="flatsuitepath" time="%"  timestamp="%"  hostname="%" >
<properties/>
<system-out/>
<system-err/>
</testsuite>%');
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
    from table(ut3.ut.run('check_junit_reporting', ut3.ut_tfs_junit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_match('time="[0-9]*\.[0-9]{3,6}"');
    --Cleanup
    execute immediate 'alter session set NLS_NUMERIC_CHARACTERS='''||l_nls_numeric_characters||'''';
  end;

  procedure check_failure_escaped is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3.ut.run('check_fail_escape',ut3.ut_tfs_junit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('%Actual: &apos;test&apos; (varchar2) was expected to equal: &apos;&lt;![CDATA[some stuff]]&gt;&apos; (varchar2)%');
  end;

  procedure check_classname_suitepath is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;    
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3.ut.run('check_junit_rep_suitepath',ut3.ut_tfs_junit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('%testcase classname="core.check_junit_rep_suitepath"%');   
  end;
  procedure remove_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package check_junit_reporting';
    execute immediate 'drop package check_junit_rep_suitepath';
    execute immediate 'drop package check_junit_flat_suitepath';
    execute immediate 'drop package check_fail_escape';
  end;
end;
/
