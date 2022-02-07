create or replace package body reporters is

  procedure create_test_helper_package is
    pragma autonomous_transaction;
  begin
  execute immediate q'[create or replace package test_reporters
as
  --%suite(A suite for testing different outcomes from reporters)
  --%suitepath(org.utplsql.tests.helpers)

  --%beforeall
  procedure beforeall;

  --%beforeeach
  procedure beforeeach;

  --%context(A description of some context)
  --%name(some_context)

  --%test
  --%beforetest(beforetest)
  --%aftertest(aftertest)
  procedure passing_test;

  --%endcontext

  procedure beforetest;

  procedure aftertest;

  --%test(a test with failing assertion)
  procedure failing_test;

  --%test(a test raising unhandled exception)
  procedure erroring_test;

  --%test(a disabled test)
  --%disabled(Disabled for testing purpose)
  procedure disabled_test;

  --%test(a disabled test with no reason)
  --%disabled
  procedure disabled_test_no_reason;

  --%aftereach
  procedure aftereach;

  --%afterall
  procedure afterall;

end;]';
  
  execute immediate q'[create or replace package body test_reporters
as

  procedure beforetest is
  begin
    dbms_output.put_line('<!beforetest!>');
  end;

  procedure aftertest
  is
  begin
    dbms_output.put_line('<!aftertest!>');
  end;

  procedure beforeeach is
  begin
    dbms_output.put_line('<!beforeeach!>');
  end;

  procedure aftereach is
  begin
    dbms_output.put_line('<!aftereach!>');
  end;

  procedure passing_test
  is
  begin
    dbms_output.put_line('<!passing test!>');
    ut3_develop.ut.expect(1,'Test 1 Should Pass').to_equal(1);
  end;

  procedure failing_test
  is
  begin
    dbms_output.put_line('<!failing test!>');
    ut3_develop.ut.expect('number [1] ','Fails as values are different').to_equal('number [2] ');
  end;

  procedure erroring_test
  is
    l_variable integer;
  begin
    dbms_output.put_line('<!erroring test!>');
    l_variable := 'a string';
    ut3_develop.ut.expect(l_variable).to_equal(1);
  end;

  procedure disabled_test
  is
  begin
    dbms_output.put_line('<!this should not execute!>');
    ut3_develop.ut.expect(1,'this should not execute').to_equal(1);
  end;

  procedure disabled_test_no_reason
  is
  begin
    dbms_output.put_line('<!this should not execute!>');
    ut3_develop.ut.expect(1,'this should not execute').to_equal(1);
  end;

  procedure beforeall is
  begin
    dbms_output.put_line('<!beforeall!>');
  end;

  procedure afterall is
  begin
    dbms_output.put_line('<!afterall!>');
  end;

end;]';

  execute immediate q'[create or replace package check_fail_escape is
      --%suitepath(core)
      --%suite(Check JUNIT XML failure is escaped)

      --%test(Fail Miserably)
      procedure fail_miserably;

    end;]';

  execute immediate q'[create or replace package body check_fail_escape is
      procedure fail_miserably is
      begin
        ut3_develop.ut.expect('test').to_equal('<![CDATA[some stuff]]>');
      end;
    end;]';

  end;
  
  procedure reporters_setup is
  begin
    create_test_helper_package; 
  end;
  
  procedure drop_test_helper_package is
  begin
    execute immediate 'drop package test_reporters';
    execute immediate 'drop package check_fail_escape';
  end;

  procedure reporters_cleanup is
    pragma autonomous_transaction;
  begin
    drop_test_helper_package; 
  end;

  procedure check_xml_encoding_included(
    a_reporter             ut3_develop.ut_reporter_base,
    a_client_character_set varchar2
  ) is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;
  begin
    --Act
    select *
    bulk collect into l_results
    from table(ut3_develop.ut.run('test_reporters', a_reporter, a_client_character_set => a_client_character_set));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('<?xml version="1.0" encoding="'||upper(a_client_character_set)||'"?>%');
  end;

  procedure check_xml_failure_escaped(
    a_reporter ut3_develop.ut_reporter_base
  ) is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;
  begin
    --Act
    select *
           bulk collect into l_results
      from table( ut3_develop.ut.run( 'check_fail_escape', a_reporter ) );
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('%<![CDATA['
      ||q'[%Actual: 'test' (varchar2) was expected to equal: '<![CDATA[some stuff]]]]><![CDATA[>' (varchar2)%]'
      ||q'[at "UT3$USER#.CHECK_FAIL_ESCAPE%", line % ut3_develop.ut.expect('test').to_equal('<![CDATA[some stuff]]]]><![CDATA[>');]'
      ||'%]]>%'
      );
  end;

end reporters;
/
