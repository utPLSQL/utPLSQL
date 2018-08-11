create or replace package body reporters is

  procedure create_test_helper_package is
    pragma autonomous_transaction;
  begin
  execute immediate q'[create or replace package test_reporters
as
  --%suite(A suite for testing different outcomes from reporters)
  --%suitepath(utplsqlorg.helpers.tests.test.test_reporters)

  --%beforeall
  procedure beforeall;

  --%beforeeach
  procedure beforeeach;

  --%test
  --%beforetest(beforetest)
  --%aftertest(aftertest)
  procedure passing_test;

  procedure beforetest;

  procedure aftertest;

  --%test(a test with failing assertion)
  procedure failing_test;

  --%test(a test raising unhandled exception)
  procedure erroring_test;

  --%test(a disabled test)
  --%disabled
  procedure disabled_test;

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
    ut3.ut.expect(1,'Test 1 Should Pass').to_equal(1);
  end;

  procedure failing_test
  is
  begin
    dbms_output.put_line('<!failing test!>');
    ut3.ut.expect('number [1] ','Fails as values are different').to_equal('number [2] ');
  end;

  procedure erroring_test
  is
    l_variable integer;
  begin
    dbms_output.put_line('<!erroring test!>');
    l_variable := 'a string';
    ut3.ut.expect(l_variable).to_equal(1);
  end;

  procedure disabled_test
  is
  begin
    dbms_output.put_line('<!this should not execute!>');
    ut3.ut.expect(1,'this should not execute').to_equal(1);
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
  
  end;
  
  procedure reporters_setup is
  begin
    create_test_helper_package; 
  end;
  
  procedure drop_test_helper_package is
  begin
    execute immediate 'drop package test_reporters';
  end;

  procedure reporters_cleanup is
    pragma autonomous_transaction;
  begin
    drop_test_helper_package; 
  end;

  procedure check_xml_encoding_included(
    a_reporter             ut3.ut_output_reporter_base,
    a_client_character_set varchar2
  ) is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
  begin
    --Act
    select *
    bulk collect into l_results
    from table(ut3.ut.run('test_reporters', a_reporter, a_client_character_set => a_client_character_set));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('<?xml version="1.0" encoding="'||upper(a_client_character_set)||'"?>%');
  end;

end reporters;
/
