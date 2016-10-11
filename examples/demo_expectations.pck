create or replace package demo_expectations is

  -- %suite(Demoing asserts)

  -- %test(demo of failure for to_equal expectation on value mismatch)
  procedure demo_to_equal_failure;

  -- %test(demo of failure for to_equal expectation on data type mismatch)
  procedure demo_to_equal_failure_types;

  -- %test(demo of success for to_equal expectation)
  procedure demo_to_equal_success;

end;
/


create or replace package body demo_expectations is

  procedure demo_to_equal_failure is
    l_expected_blob          blob     := to_blob('AF12FF');
    l_expected_boolean       boolean  := true;
    l_expected_clob          clob     := 'a string';
    l_expected_date          date     := sysdate;
    l_expected_number        number   := 12345;
    l_expected_timestamp     timestamp with time zone := sysdate;
    l_expected_timestamp_ltz timestamp with local time zone := sysdate;
    l_expected_timestamp_tz  timestamp with time zone := sysdate;
    l_expected_varchar2      varchar2(100) := 'a string';
    l_actual_blob            blob     := to_blob('AF');
    l_actual_boolean         boolean  := false;
    l_actual_clob            clob     := 'a different string';
    l_actual_date            date     := sysdate - 1;
    l_actual_number          number   := 0.12345;
    l_actual_timestamp       timestamp with time zone := sysdate - 1;
    l_actual_timestamp_ltz   timestamp with local time zone := sysdate - 1;
    l_actual_timestamp_tz    timestamp with time zone := sysdate - 1;
    l_actual_varchar2        varchar2(100) := 'a different string';
  begin
    ut.expect( l_actual_blob ).to_equal( l_expected_blob );
    ut.expect( l_actual_boolean ).to_equal( l_expected_boolean );
    ut.expect( l_actual_clob ).to_equal( l_expected_clob );
    ut.expect( l_actual_date ).to_equal( l_expected_date );
    ut.expect( l_actual_number ).to_equal( l_expected_number );
    ut.expect( l_actual_timestamp ).to_equal( l_expected_timestamp );
    ut.expect( l_actual_timestamp_ltz ).to_equal( l_expected_timestamp_ltz );
    ut.expect( l_actual_timestamp_tz ).to_equal( l_expected_timestamp_tz );
    ut.expect( l_actual_varchar2 ).to_equal( l_expected_varchar2 );

    ut.expect( l_actual_blob ).to_( equal( l_expected_blob ) );
    ut.expect( l_actual_boolean ).to_( equal( l_expected_boolean ) );
    ut.expect( l_actual_clob ).to_( equal( l_expected_clob ) );
    ut.expect( l_actual_date ).to_( equal( l_expected_date ) );
    ut.expect( l_actual_number ).to_( equal( l_expected_number ) );
    ut.expect( l_actual_timestamp ).to_( equal( l_expected_timestamp ) );
    ut.expect( l_actual_timestamp_ltz ).to_( equal( l_expected_timestamp_ltz ) );
    ut.expect( l_actual_timestamp_tz ).to_( equal( l_expected_timestamp_tz ) );
    ut.expect( l_actual_varchar2 ).to_( equal( l_expected_varchar2 ) );

    ut.expect( false ).to_be_true;
    ut.expect( false ).to_( be_true );

  end;

  procedure demo_to_equal_failure_types is
    l_blob          blob     := to_blob('AF12FF');
    l_boolean       boolean  := true;
    l_clob          clob     := 'a string';
    l_date          date     := sysdate;
    l_number        number   := 12345;
    l_timestamp     timestamp with time zone := sysdate;
    l_timestamp_ltz timestamp with local time zone := sysdate;
    l_timestamp_tz  timestamp with time zone := sysdate;
    l_varchar2      varchar2(100) := 'a string';
  begin
    ut.expect( l_blob ).to_equal( l_clob );
    ut.expect( l_boolean ).to_equal( l_number );
    ut.expect( l_clob ).to_equal( l_blob );
    ut.expect( l_date ).to_equal( l_timestamp );
    ut.expect( l_number ).to_equal( l_varchar2 );
    ut.expect( l_timestamp ).to_equal( l_timestamp_ltz );
    ut.expect( l_timestamp ).to_equal( l_timestamp_tz );
    ut.expect( l_timestamp_ltz ).to_equal( l_date );
    ut.expect( l_varchar2 ).to_equal( l_clob );

    ut.expect( l_blob ).to_( equal( l_clob ) );
    ut.expect( l_boolean ).to_( equal( l_number ) );
    ut.expect( l_clob ).to_( equal( l_blob ) );
    ut.expect( l_date ).to_( equal( l_timestamp ) );
    ut.expect( l_number ).to_( equal( l_varchar2 ) );
    ut.expect( l_timestamp ).to_( equal( l_timestamp_ltz ) );
    ut.expect( l_timestamp ).to_( equal( l_timestamp_tz ) );
    ut.expect( l_timestamp_ltz ).to_( equal( l_date ) );
    ut.expect( l_varchar2 ).to_( equal( l_clob ) );

    --ut.expect( l_varchar2 ).to_be_true; -- this will not compile
    ut.expect( l_varchar2 ).to_( be_true );

  end;


  procedure demo_to_equal_success is
    l_blob          blob     := to_blob('AF12FF');
    l_boolean       boolean  := true;
    l_clob          clob     := 'a string';
    l_date          date     := sysdate;
    l_number        number   := 12345;
    l_timestamp     timestamp with time zone := sysdate;
    l_timestamp_ltz timestamp with local time zone := sysdate;
    l_timestamp_tz  timestamp with time zone := sysdate;
    l_varchar2      varchar2(100) := 'a string';
  begin
    ut.expect( l_blob ).to_equal( l_blob );
    ut.expect( l_boolean ).to_equal( l_boolean );
    ut.expect( l_clob ).to_equal( l_clob );
    ut.expect( l_date ).to_equal( l_date );
    ut.expect( l_number ).to_equal( l_number );
    ut.expect( l_timestamp ).to_equal( l_timestamp );
    ut.expect( l_timestamp_ltz ).to_equal( l_timestamp_ltz );
    ut.expect( l_timestamp_tz ).to_equal( l_timestamp_tz );
    ut.expect( l_varchar2 ).to_equal( l_varchar2 );

    ut.expect( l_blob ).to_( equal( l_blob ) );
    ut.expect( l_boolean ).to_( equal( l_boolean ) );
    ut.expect( l_clob ).to_( equal( l_clob ) );
    ut.expect( l_date ).to_( equal( l_date ) );
    ut.expect( l_number ).to_( equal( l_number ) );
    ut.expect( l_timestamp ).to_( equal( l_timestamp ) );
    ut.expect( l_timestamp_ltz ).to_( equal( l_timestamp_ltz ) );
    ut.expect( l_timestamp_tz ).to_( equal( l_timestamp_tz ) );
    ut.expect( l_varchar2 ).to_( equal( l_varchar2 ) );

    ut.expect( true ).to_be_true;
    ut.expect( true ).to_( be_true );

  end;

end;
/
