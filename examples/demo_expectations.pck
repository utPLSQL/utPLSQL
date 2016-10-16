create or replace package demo_expectations is

  -- %suite(Demoing asserts)

  -- %test(demo of failure for to_equal expectation on value mismatch)
  procedure demo_to_equal_failure;

  -- %test(demo of failure for to_equal expectation on data type mismatch)
  procedure demo_to_equal_failure_types;

  -- %test(demo of success for to_equal expectation)
  procedure demo_to_equal_success;

  -- %test(demo of failure for to_be_true and to_be_false expectation)
  procedure demo_to_be_true_false_failure;

  -- %test(demo of success for to_be_true and to_be_false expectation)
  procedure demo_to_be_true_false_success;

  -- %test(demo of failure for to_be_null expectation )
  procedure demo_to_be_null_failure;

  -- %test(demo of failure for to_be_null expectation )
  procedure demo_to_be_null_success;

  -- %test(demo of success for to_be_not_null expectation )
  procedure demo_to_be_not_null_failure;

  -- %test(demo of success for to_be_not_null expectation)
  procedure demo_to_be_not_null_success;

end;
/


create or replace package body demo_expectations is

  procedure demo_to_equal_failure is
    l_expected_anydata       anydata  := anydata.convertObject( department$('IT') );
    l_expected_blob          blob     := to_blob('AF12FF');
    l_expected_boolean       boolean  := true;
    l_expected_clob          clob     := 'a string';
    l_expected_date          date     := sysdate;
    l_expected_number        number   := 12345;
    l_expected_timestamp     timestamp with time zone := sysdate;
    l_expected_timestamp_ltz timestamp with local time zone := sysdate;
    l_expected_timestamp_tz  timestamp with time zone := sysdate;
    l_expected_varchar2      varchar2(100) := 'a string';
    l_actual_anydata         anydata  := anydata.convertCollection( departments$( department$('IT'), department$('HR') ) );
    l_actual_blob            blob     := to_blob('AF');
    l_actual_boolean         boolean  := false;
    l_actual_clob            clob     := 'a different string';
    l_actual_date            date     := sysdate - 1;
    l_actual_number          number   := 0.12345;
    l_actual_timestamp       timestamp with time zone := sysdate - 1;
    l_actual_timestamp_ltz   timestamp with local time zone := sysdate - 1;
    l_actual_timestamp_tz    timestamp with time zone := sysdate - 1;
    l_actual_varchar2        varchar2(100) := 'a different string';
    l_actual_cursor          sys_refcursor;
    l_expected_cursor        sys_refcursor;
  begin
    --using the to_equal( ) matcher
    ut.expect( l_actual_anydata ).to_equal( l_expected_anydata );
    ut.expect( l_actual_blob ).to_equal( l_expected_blob );
    ut.expect( l_actual_boolean ).to_equal( l_expected_boolean );
    ut.expect( l_actual_clob ).to_equal( l_expected_clob );
    ut.expect( l_actual_date ).to_equal( l_expected_date );
    ut.expect( l_actual_number ).to_equal( l_expected_number );
    ut.expect( l_actual_timestamp ).to_equal( l_expected_timestamp );
    ut.expect( l_actual_timestamp_ltz ).to_equal( l_expected_timestamp_ltz );
    ut.expect( l_actual_timestamp_tz ).to_equal( l_expected_timestamp_tz );
    ut.expect( l_actual_varchar2 ).to_equal( l_expected_varchar2 );

    --using the to_( equal( ) ) matcher
    ut.expect( l_actual_anydata ).to_( equal( l_expected_anydata ) );
    ut.expect( l_actual_blob ).to_( equal( l_expected_blob ) );
    ut.expect( l_actual_boolean ).to_( equal( l_expected_boolean ) );
    ut.expect( l_actual_clob ).to_( equal( l_expected_clob ) );
    ut.expect( l_actual_date ).to_( equal( l_expected_date ) );
    ut.expect( l_actual_number ).to_( equal( l_expected_number ) );
    ut.expect( l_actual_timestamp ).to_( equal( l_expected_timestamp ) );
    ut.expect( l_actual_timestamp_ltz ).to_( equal( l_expected_timestamp_ltz ) );
    ut.expect( l_actual_timestamp_tz ).to_( equal( l_expected_timestamp_tz ) );
    ut.expect( l_actual_varchar2 ).to_( equal( l_expected_varchar2 ) );

    open l_actual_cursor for select * from user_objects where rownum <100;
    open l_expected_cursor for select * from user_objects where rownum <5;

    ut.expect(l_actual_cursor).to_equal(l_expected_cursor);

  end;

  procedure demo_to_equal_failure_types is
    l_anydata       anydata  := anydata.convertObject( department$('IT') );
    l_blob          blob     := to_blob('AF12FF');
    l_boolean       boolean  := true;
    l_clob          clob     := 'a string';
    l_date          date     := sysdate;
    l_number        number   := 12345;
    l_cursor        sys_refcursor;
    l_timestamp     timestamp with time zone := sysdate;
    l_timestamp_ltz timestamp with local time zone := sysdate;
    l_timestamp_tz  timestamp with time zone := sysdate;
    l_varchar2      varchar2(100) := 'a string';
  begin
    --using the to_equal( ) matcher
    ut.expect( l_anydata ).to_equal( l_clob );
    ut.expect( l_blob ).to_equal( l_clob );
    ut.expect( l_boolean ).to_equal( l_number );
    ut.expect( l_clob ).to_equal( l_blob );
    ut.expect( l_date ).to_equal( l_timestamp );
    ut.expect( l_number ).to_equal( l_varchar2 );
    ut.expect( l_timestamp ).to_equal( l_timestamp_ltz );
    ut.expect( l_timestamp ).to_equal( l_timestamp_tz );
    ut.expect( l_timestamp_ltz ).to_equal( l_date );
    ut.expect( l_varchar2 ).to_equal( l_clob );
    open l_cursor for select * from user_objects where rownum <100;
    ut.expect( l_cursor ).to_equal( l_varchar2 );

    --using the to_( equal( ) ) matcher
    ut.expect( l_clob ).to_( equal( l_anydata ) );
    ut.expect( l_blob ).to_( equal( l_clob ) );
    ut.expect( l_boolean ).to_( equal( l_number ) );
    ut.expect( l_clob ).to_( equal( l_blob ) );
    ut.expect( l_date ).to_( equal( l_timestamp ) );
    ut.expect( l_number ).to_( equal( l_varchar2 ) );
    ut.expect( l_timestamp ).to_( equal( l_timestamp_ltz ) );
    ut.expect( l_timestamp ).to_( equal( l_timestamp_tz ) );
    ut.expect( l_timestamp_ltz ).to_( equal( l_date ) );
    ut.expect( l_varchar2 ).to_( equal( l_clob ) );
    open l_cursor for select * from user_objects where rownum <100;
    ut.expect( l_varchar2 ).to_( equal( l_cursor ) );

  end;


  procedure demo_to_equal_success is
    l_anydata       anydata  := anydata.convertObject( department$('IT') );
    l_blob          blob     := to_blob('AF12FF');
    l_boolean       boolean  := true;
    l_clob          clob     := 'a string';
    l_date          date     := sysdate;
    l_number        number   := 12345;
    l_timestamp     timestamp with time zone := sysdate;
    l_timestamp_ltz timestamp with local time zone := sysdate;
    l_timestamp_tz  timestamp with time zone := sysdate;
    l_varchar2      varchar2(100) := 'a string';
    l_cursor1        sys_refcursor;
    l_cursor2        sys_refcursor;
  begin
    --using the to_equal( ) matcher
    ut.expect( l_anydata ).to_equal( l_anydata );
    ut.expect( l_blob ).to_equal( l_blob );
    ut.expect( l_boolean ).to_equal( l_boolean );
    ut.expect( l_clob ).to_equal( l_clob );
    ut.expect( l_date ).to_equal( l_date );
    ut.expect( l_number ).to_equal( l_number );
    ut.expect( l_timestamp ).to_equal( l_timestamp );
    ut.expect( l_timestamp_ltz ).to_equal( l_timestamp_ltz );
    ut.expect( l_timestamp_tz ).to_equal( l_timestamp_tz );
    ut.expect( l_varchar2 ).to_equal( l_varchar2 );
    open l_cursor1 for select * from all_objects;
    open l_cursor2 for select * from all_objects;
    ut.expect( l_cursor1 ).to_equal( l_cursor2 );

    --using the to_( equal( ) ) matcher
    ut.expect( l_anydata ).to_( equal( l_anydata ) );
    ut.expect( l_blob ).to_( equal( l_blob ) );
    ut.expect( l_boolean ).to_( equal( l_boolean ) );
    ut.expect( l_clob ).to_( equal( l_clob ) );
    ut.expect( l_date ).to_( equal( l_date ) );
    ut.expect( l_number ).to_( equal( l_number ) );
    ut.expect( l_timestamp ).to_( equal( l_timestamp ) );
    ut.expect( l_timestamp_ltz ).to_( equal( l_timestamp_ltz ) );
    ut.expect( l_timestamp_tz ).to_( equal( l_timestamp_tz ) );
    ut.expect( l_varchar2 ).to_( equal( l_varchar2 ) );

    open l_cursor1 for select * from all_objects;
    open l_cursor2 for select * from all_objects;
    ut.expect( l_cursor1 ).to_( equal( l_cursor2 ) );
  end;

  procedure demo_to_be_true_false_failure is
    l_null_boolean boolean;
  begin
    ut.expect( false ).to_be_true;
    ut.expect( false ).to_( be_true );
    ut.expect( false ).to_( be_true() );
    ut.expect( l_null_boolean ).to_be_true;
    ut.expect( l_null_boolean ).to_( be_true );
    ut.expect( l_null_boolean ).to_( be_true() );

    ut.expect( true ).to_be_false;
    ut.expect( true ).to_( be_false );
    ut.expect( true ).to_( be_false() );
    ut.expect( l_null_boolean ).to_be_false;
    ut.expect( l_null_boolean ).to_( be_false );
    ut.expect( l_null_boolean ).to_( be_false() );
  end;

  procedure demo_to_be_true_false_success is
  begin
    ut.expect( true ).to_be_true;
    ut.expect( true ).to_( be_true );
    ut.expect( true ).to_( be_true() );

    ut.expect( false ).to_be_false;
    ut.expect( false ).to_( be_false );
    ut.expect( false ).to_( be_false() );
  end;

  -- %test(demo of failure for to_be_null expectation )
  procedure demo_to_be_null_failure is
    l_anydata       anydata  := anydata.convertObject( department$('IT') );
    l_blob          blob     := to_blob('AF12FF');
    l_boolean       boolean  := true;
    l_clob          clob     := 'a string';
    l_date          date     := sysdate;
    l_number        number   := 12345;
    l_cursor        sys_refcursor;
    l_timestamp     timestamp with time zone := sysdate;
    l_timestamp_ltz timestamp with local time zone := sysdate;
    l_timestamp_tz  timestamp with time zone := sysdate;
    l_varchar2      varchar2(100) := 'a string';
  begin
    open l_cursor for select * from user_objects where rownum <100;
    --using the to_be_null() matcher
    ut.expect( l_anydata ).to_be_null();
    ut.expect( l_blob ).to_be_null();
    ut.expect( l_boolean ).to_be_null();
    ut.expect( l_clob ).to_be_null();
    ut.expect( l_date ).to_be_null();
    ut.expect( l_number ).to_be_null;
    ut.expect( l_timestamp ).to_be_null;
    ut.expect( l_timestamp ).to_be_null;
    ut.expect( l_timestamp_ltz ).to_be_null;
    ut.expect( l_varchar2 ).to_be_null;
    ut.expect( l_cursor ).to_be_null;

    --using the to_( be_null() ) matcher
    open l_cursor for select * from user_objects where rownum <100;
    ut.expect( l_anydata ).to_( be_null() );
    ut.expect( l_blob ).to_( be_null() );
    ut.expect( l_boolean ).to_( be_null() );
    ut.expect( l_clob ).to_( be_null() );
    ut.expect( l_date ).to_( be_null() );
    ut.expect( l_number ).to_( be_null );
    ut.expect( l_timestamp ).to_( be_null );
    ut.expect( l_timestamp ).to_( be_null );
    ut.expect( l_timestamp_ltz ).to_( be_null );
    ut.expect( l_varchar2 ).to_( be_null );
    ut.expect( l_cursor ).to_( be_null );
  end;

  -- %test(demo of failure for to_be_null expectation )
  procedure demo_to_be_null_success is
    l_obj              department$;
    l_col              departments$;
    l_null_anydata_tab anydata  := anydata.convertObject( l_obj );
    l_null_anydata_obj anydata  := anydata.convertCollection( l_col );
    l_anydata          anydata ;
    l_blob             blob    ;
    l_boolean          boolean ;
    l_clob             clob    ;
    l_date             date    ;
    l_number           number  ;
    l_cursor           sys_refcursor;
    l_timestamp        timestamp with time zone;
    l_timestamp_ltz    timestamp with local time zone;
    l_timestamp_tz     timestamp with time zone;
    l_varchar2         varchar2(100);
  begin
    --using the to_be_null() matcher
    ut.expect( l_null_anydata_tab ).to_be_null();
    ut.expect( l_null_anydata_obj ).to_be_null();
    ut.expect( l_anydata ).to_be_null();
    ut.expect( l_blob ).to_be_null();
    ut.expect( l_boolean ).to_be_null();
    ut.expect( l_clob ).to_be_null();
    ut.expect( l_date ).to_be_null();
    ut.expect( l_number ).to_be_null;
    ut.expect( l_timestamp ).to_be_null;
    ut.expect( l_timestamp ).to_be_null;
    ut.expect( l_timestamp_ltz ).to_be_null;
    ut.expect( l_varchar2 ).to_be_null;
    ut.expect( l_cursor ).to_be_null;

    --using the to_( be_null() ) matcher
    ut.expect( l_null_anydata_tab ).to_( be_null() );
    ut.expect( l_null_anydata_obj ).to_( be_null() );
    ut.expect( l_anydata ).to_( be_null() );
    ut.expect( l_blob ).to_( be_null() );
    ut.expect( l_boolean ).to_( be_null() );
    ut.expect( l_clob ).to_( be_null() );
    ut.expect( l_date ).to_( be_null() );
    ut.expect( l_number ).to_( be_null );
    ut.expect( l_timestamp ).to_( be_null );
    ut.expect( l_timestamp ).to_( be_null );
    ut.expect( l_timestamp_ltz ).to_( be_null );
    ut.expect( l_varchar2 ).to_( be_null );
    ut.expect( l_cursor ).to_( be_null );
  end;

  -- %test(demo of success for to_be_not_null expectation )
  procedure demo_to_be_not_null_failure is
    l_obj              department$;
    l_col              departments$;
    l_null_anydata_tab anydata  := anydata.convertObject( l_obj );
    l_null_anydata_obj anydata  := anydata.convertCollection( l_col );
    l_anydata          anydata ;
    l_blob             blob    ;
    l_boolean          boolean ;
    l_clob             clob    ;
    l_date             date    ;
    l_number           number  ;
    l_cursor           sys_refcursor;
    l_timestamp        timestamp with time zone;
    l_timestamp_ltz    timestamp with local time zone;
    l_timestamp_tz     timestamp with time zone;
    l_varchar2         varchar2(100);
  begin
    --using the to_be_not_null() matcher
    ut.expect( l_null_anydata_tab ).to_be_not_null();
    ut.expect( l_null_anydata_obj ).to_be_not_null();
    ut.expect( l_anydata ).to_be_not_null();
    ut.expect( l_blob ).to_be_not_null();
    ut.expect( l_boolean ).to_be_not_null();
    ut.expect( l_clob ).to_be_not_null();
    ut.expect( l_date ).to_be_not_null();
    ut.expect( l_number ).to_be_not_null;
    ut.expect( l_timestamp ).to_be_not_null;
    ut.expect( l_timestamp ).to_be_not_null;
    ut.expect( l_timestamp_ltz ).to_be_not_null;
    ut.expect( l_varchar2 ).to_be_not_null;
    ut.expect( l_cursor ).to_be_not_null;

    --using the to_( be_not_null() ) matcher
    ut.expect( l_null_anydata_tab ).to_( be_not_null() );
    ut.expect( l_null_anydata_obj ).to_( be_not_null() );
    ut.expect( l_anydata ).to_( be_not_null() );
    ut.expect( l_blob ).to_( be_not_null() );
    ut.expect( l_boolean ).to_( be_not_null() );
    ut.expect( l_clob ).to_( be_not_null() );
    ut.expect( l_date ).to_( be_not_null() );
    ut.expect( l_number ).to_( be_not_null );
    ut.expect( l_timestamp ).to_( be_not_null );
    ut.expect( l_timestamp ).to_( be_not_null );
    ut.expect( l_timestamp_ltz ).to_( be_not_null );
    ut.expect( l_varchar2 ).to_( be_not_null );
    ut.expect( l_cursor ).to_( be_not_null );
  end;

  -- %test(demo of success for to_be_not_null expectation)
  procedure demo_to_be_not_null_success is
    l_anydata       anydata  := anydata.convertObject( department$('IT') );
    l_blob          blob     := to_blob('AF12FF');
    l_boolean       boolean  := true;
    l_clob          clob     := 'a string';
    l_date          date     := sysdate;
    l_number        number   := 12345;
    l_cursor        sys_refcursor;
    l_timestamp     timestamp with time zone := sysdate;
    l_timestamp_ltz timestamp with local time zone := sysdate;
    l_timestamp_tz  timestamp with time zone := sysdate;
    l_varchar2      varchar2(100) := 'a string';
  begin
    open l_cursor for select * from user_objects where rownum <100;
    --using the to_be_not_null() matcher
    ut.expect( l_anydata ).to_be_not_null();
    ut.expect( l_blob ).to_be_not_null();
    ut.expect( l_boolean ).to_be_not_null();
    ut.expect( l_clob ).to_be_not_null();
    ut.expect( l_date ).to_be_not_null();
    ut.expect( l_number ).to_be_not_null;
    ut.expect( l_timestamp ).to_be_not_null;
    ut.expect( l_timestamp ).to_be_not_null;
    ut.expect( l_timestamp_ltz ).to_be_not_null;
    ut.expect( l_varchar2 ).to_be_not_null;
    ut.expect( l_cursor ).to_be_not_null;

    --using the to_( be_not_null() ) matcher
    open l_cursor for select * from user_objects where rownum <100;
    ut.expect( l_anydata ).to_( be_not_null() );
    ut.expect( l_blob ).to_( be_not_null() );
    ut.expect( l_boolean ).to_( be_not_null() );
    ut.expect( l_clob ).to_( be_not_null() );
    ut.expect( l_date ).to_( be_not_null() );
    ut.expect( l_number ).to_( be_not_null );
    ut.expect( l_timestamp ).to_( be_not_null );
    ut.expect( l_timestamp ).to_( be_not_null );
    ut.expect( l_timestamp_ltz ).to_( be_not_null );
    ut.expect( l_varchar2 ).to_( be_not_null );
    ut.expect( l_cursor ).to_( be_not_null );
  end;

end;
/
