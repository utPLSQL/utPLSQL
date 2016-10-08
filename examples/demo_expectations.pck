drop package demo_expectations;

create or replace package demo_expectations is

  -- %suite(Demoing asserts)

  -- %test(success of equal varchar)
  procedure test1;

  -- %test(failure of different varchar)
  procedure test2;

  -- %test(success of equal number)
  procedure test3;

  -- %test(failure of different number)
  procedure test4;

  -- %test(success of equal clob)
  procedure test5;

  -- %test(failure of different clob)
  procedure test6;

  -- %test(failure varchar with clob)
  procedure test7;

  -- %test(failure of clob with varchar)
  procedure test8;

  -- %test(failure varchar with number)
  procedure test9;

  -- %test(failure of number with varchar)
  procedure test10;

  -- %test(failure number with clob)
  procedure test11;


  -- %test(failure of clob with number)
  procedure test12;

  -- %test(success of equal blob)
  procedure test13;

  -- %test(failure of different blob)
  procedure test14;

  -- %test(failure of clob with blob)
  procedure test15;

  -- %test(failure of blob with clob)
  procedure test16;

  -- %test(expectation using ut.expect('value').to_(equal('value'));)
  procedure test17;
end;
/


create or replace package body demo_expectations is

  -- %test(success of equal varchar)
  procedure test1 is
  begin
    ut.expect( 'a varchar2 value' ).to_equal('a varchar2 value');
  end;

  -- %test(failure of different varchar)
  procedure test2 is
  begin
    ut.expect('a varchar2 value').to_equal('a differernt varchar2 value');
  end;


  -- %test(success of equal number)
  procedure test3 is
  begin
    ut.expect(12345).to_equal(12345);
  end;


  -- %test(failure of different number)
  procedure test4 is
  begin
    ut.expect(.0987654321).to_equal(.09876543210987654321);
  end;


  -- %test(success of equal clob)
  procedure test5 is
    a clob := 'a3';
    b clob := 'a3';
  begin
    ut.expect(a).to_equal(b);
  end;

  -- %test(failure of different clob)
  procedure test6 is
    a clob := 'a3';
    b clob := 'a4';
  begin
    ut.expect(a).to_equal(b);
  end;

  -- %test(failure varchar with clob)
  procedure test7 is
    a clob := 'a3';
  begin
    ut.expect(a).to_equal('a3');
  end;


  -- %test(failure of clob with varchar)
  procedure test8 is
    a clob := 'a3';
  begin
    ut.expect('a3').to_equal(a);
  end;

  -- %test(failure varchar with number)
  procedure test9 is
  begin
    ut.expect('12345').to_equal(12345);
  end;

  -- %test(failure of number with varchar)
  procedure test10 is
  begin
    ut.expect(12345).to_equal('12345');
  end;

  -- %test(failure number with clob)
  procedure test11 is
    a clob := '3';
  begin
    ut.expect(a).to_equal(3);
  end;


  -- %test(failure of clob with number)
  procedure test12 is
    a clob := '3';
  begin
    ut.expect(3).to_equal(a);
  end;

  -- %test(success of equal blob)
  procedure test13 is
    a blob := utl_raw.cast_to_raw('a3');
    b blob := utl_raw.cast_to_raw('a3');
  begin
    ut.expect(a).to_equal(b);
  end;

  -- %test(failure of different blob)
  procedure test14 is
    a blob := utl_raw.cast_to_raw('a3');
    b blob := utl_raw.cast_to_raw('a4');
  begin
    ut.expect(a).to_equal(b);
  end;

  -- %test(failure of clob with blob)
  procedure test15 is
    a clob := 'a3';
    b blob := utl_raw.cast_to_raw('a3');
  begin
    ut.expect(a).to_equal(b);
  end;

  -- %test(failure of blob with clob)
  procedure test16 is
    a blob := utl_raw.cast_to_raw('a3');
    b clob := 'a3';
  begin
    ut.expect(a).to_equal(b);
  end;

  -- %test(expectation using ut.expect('value').to_(equal('value'));)
  procedure test17 is
  begin
    ut.expect('value').to_(equal('value'));
  end;

end;
/
