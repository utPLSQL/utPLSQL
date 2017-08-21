create or replace package body test_reporters
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
    ut.expect(1,'Test 1 Should Pass').to_equal(1);
  end;

  procedure failing_test
  is
  begin
    dbms_output.put_line('<!failing test!>');
    ut.expect(1,'Fails as values are different').to_equal(2);
  end;

  procedure erroring_test
  is
    l_variable integer;
  begin
    dbms_output.put_line('<!erroring test!>');
    l_variable := 'a string';
    ut.expect(l_variable).to_equal(1);
  end;

  procedure disabled_test
  is
  begin
    dbms_output.put_line('<!this should not execute!>');
    ut.expect(1,'this should not execute').to_equal(1);
  end;

  procedure beforeall is
  begin
    dbms_output.put_line('<!beforeall!>');
  end;

  procedure afterall is
  begin
    dbms_output.put_line('<!afterall!>');
  end;

end;
/

