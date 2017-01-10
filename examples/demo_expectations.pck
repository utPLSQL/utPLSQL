create or replace package demo_expectations is

  -- %suite
  -- %displayname(Demoing asserts)

  -- %test
  -- %displayname(demo of expectations with nulls)
  procedure demo_nulls_on_expectations;

  -- %test
  -- %displayname(demo of failure for to_equal expectation on value mismatch)
  procedure demo_to_equal_failure;

  -- %test
  -- %displayname(demo of failure for to_equal expectation on data type mismatch)
  procedure demo_to_equal_failure_types;

  -- %test
  -- %displayname(demo of success for to_equal expectation)
  procedure demo_to_equal_success;

  -- %test
  -- %displayname(demo of failure for to_be_true and to_be_false expectation)
  procedure demo_to_be_true_false_failure;

  -- %test
  -- %displayname(demo of success for to_be_true and to_be_false expectation)
  procedure demo_to_be_true_false_success;

  -- %test
  -- %displayname(demo of failure for to_be_null expectation )
  procedure demo_to_be_null_failure;

  -- %test
  -- %displayname(demo of failure for to_be_null expectation )
  procedure demo_to_be_null_success;

  -- %test
  -- %displayname(demo of success for to_be_not_null expectation )
  procedure demo_to_be_not_null_failure;

  -- %test
  -- %displayname(demo of success for to_be_not_null expectation)
  procedure demo_to_be_not_null_success;

  -- %test
  -- %displayname(demo of failure for to_match expectation)
  procedure demo_to_match_failure;

  -- %test
  -- %displayname(demo of success for to_match expectation)
  procedure demo_to_match_success;

  -- %test
  -- %displayname(demo of failure for to_be_like expectation)
  procedure demo_to_be_like_failure;

  -- %test
  -- %displayname(demo of success for to_be_like expectation)
  procedure demo_to_be_like_success;

  -- %test
  -- %displayname(demo of failure for not_to expectations)
  procedure demo_not_to_failure;

  -- %test
  -- %displayname(demo of success for not_to expectations)
  procedure demo_not_to_success;

end;
/
create or replace package body demo_expectations is

  procedure demo_nulls_on_expectations is
  begin
    --fails on incompatible data types
    ut.expect( to_clob('a text'), 'this should fail' ).to_equal( 'a text' );
    ut.expect( to_clob('a text'), 'this should fail' ).to_( equal( 'a text' ) );
    ut.expect( cast(systimestamp as timestamp), 'this should fail' ).to_( equal( systimestamp ) );
    ut.expect( to_clob('a text'), 'this should fail' ).not_to( equal( 'a text' ) );
    ut.expect( cast(systimestamp as timestamp), 'this should fail' ).not_to( equal( systimestamp ) );

    --fails on incompatible data types even if values are null
    ut.expect( to_char(null), 'this should fail' ).to_( equal( to_char(null) ) );
    ut.expect( to_char(null), 'this should fail' ).not_to( equal( to_char(null) ) );

    --fails on nulls not beeig equal
    ut_assert_processor.nulls_are_equal(false);
    ut.expect( to_char(null), 'fails when global null_are_equal=false' ).to_( equal(to_char(null) ) );
    ut_assert_processor.nulls_are_equal( true );
    ut.expect( to_char(null), 'fails when local null_are_equal=false' ).to_( equal(to_char(null), a_nulls_are_equal => false ) );

    --succeeds when nulls are considered equal
    ut_assert_processor.nulls_are_equal(false);
    ut.expect( to_char(null) , 'succeeds when local null_are_equal=true' ).to_( equal( to_char(null), a_nulls_are_equal => true ) );
    ut_assert_processor.nulls_are_equal( true );
    ut.expect( to_char(null), 'succeeds when global null_are_equal=true' ).to_( equal( to_char(null) ) );

    --fails as null is not comparable with not null
    ut.expect( to_char(null), 'fails on null = not null' ).to_( equal( 'a text' ) );
    ut.expect( 'a text', 'fails on not null = null' ).to_( equal( to_char(null) ) );
    ut.expect( to_char(null), 'fails on null <> not null' ).not_to( equal( 'a text' ) );
    ut.expect( 'a text', 'fails on not null <> null' ).not_to( equal( to_char(null) ) );
    ut.expect( to_char(null), 'fails on null <> not null, with a_nulls_are_equal => true' ).not_to( equal( 'a text', a_nulls_are_equal => true ) );
    ut.expect( 'a text', 'fails on not null <> null, with a_nulls_are_equal => false' ).not_to( equal( to_char(null), a_nulls_are_equal => false ) );

    ut.expect( to_char(null), 'fails on null like ''text''' ).to_( be_like( 'a text' ) );
    ut.expect( to_char(null), 'fails on null not like ''text''' ).not_to( be_like( 'a text' ) );

    ut.expect( cast(null as boolean), 'fails on null = true' ).to_( be_true );
    ut.expect( cast(null as boolean), 'fails on null <> true' ).not_to( be_true );
    ut.expect( cast(null as boolean), 'fails on null = false' ).to_( be_false );
    ut.expect( cast(null as boolean), 'fails on null <> false' ).not_to( be_false );

  end;

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

    open l_actual_cursor for select * from user_objects where rownum <6;
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
    open l_cursor for select * from user_objects where rownum <5;
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
    open l_cursor for select * from user_objects where rownum <5;
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
    open l_cursor1 for select * from all_objects where rownum <=50;
    open l_cursor2 for select * from all_objects where rownum <=50;
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

    open l_cursor1 for select * from all_objects where rownum <=50;
    open l_cursor2 for select * from all_objects where rownum <=50;
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

    ut.expect( 'a string value' ).to_( be_true() );

    ut.expect( true ).to_be_false;
    ut.expect( true ).to_( be_false );
    ut.expect( true ).to_( be_false() );
    ut.expect( l_null_boolean ).to_be_false;
    ut.expect( l_null_boolean ).to_( be_false );
    ut.expect( l_null_boolean ).to_( be_false() );

    ut.expect( 'a string value' ).to_( be_false() );
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
    l_timestamp     timestamp with time zone := systimestamp;
    l_timestamp_ltz timestamp with local time zone := l_timestamp;
    l_timestamp_tz  timestamp with time zone := l_timestamp;
    l_varchar2      varchar2(100) := 'a string';
  begin
    open l_cursor for select * from user_objects where rownum <5;
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
    open l_cursor for select * from user_objects where rownum <5;
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
    open l_cursor for select * from user_objects where rownum <5;
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
    open l_cursor for select * from user_objects where rownum <5;
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

  procedure demo_to_match_failure is
    l_clob  clob := 'There was a guy named Stephen';
  begin
    ut.expect( 'STEPHEN' ).to_match('^Stephen$');
    ut.expect( 'stephen ' ).to_match('^Stephen$', 'i'); --case insensitive
    ut.expect( 'stephen' ).to_( match('^Stephen$') );
    ut.expect( 'stephen ' ).to_( match('^Stephen$', 'i') ); --case insensitive
    ut.expect( l_clob ).to_match('^Stephen$');
    ut.expect( l_clob ).to_match('^Stephen$', 'i'); --case insensitive
    ut.expect( l_clob ).to_( match('^Stephen$') );
    ut.expect( l_clob ).to_( match('^Stephen$', 'i') ); --case insensitive

    ut.expect( sysdate ).to_( match(sysdate, 'i') ); --case insensitive
    ut.expect( 12345 ).to_( match(12345, 'i') ); --case insensitive

  end;

  procedure demo_to_match_success is
    l_clob  clob := 'There was a guy named STEPHEN';
  begin
    ut.expect( 'Hi, I am Stephen' ).to_match('Stephen$');
    ut.expect( 'stephen' ).to_match('^Stephen$', 'i'); --case insensitive
    ut.expect( 'Hi, I am Stephen' ).to_( match('Stephen$') );
    ut.expect( 'stephen' ).to_( match('^Stephen$', 'i') ); --case insensitive
    ut.expect( l_clob ).to_match('STEPHEN');
    ut.expect( l_clob ).to_match('Stephen$', 'i'); --case insensitive
    ut.expect( l_clob ).to_( match('STEPHEN$') );
    ut.expect( l_clob ).to_( match('Stephen$', 'i') ); --case insensitive
  end;

  procedure demo_to_be_like_failure is
    l_clob  clob := 'There was a guy named Stephen';
  begin
    ut.expect( 'STEPHEN' ).to_be_like('Stephen');
    ut.expect( 'Stephen ' ).to_be_like('Stephen\_', '\'); --escape wildcards with '\'
    ut.expect( 'stephen' ).to_( be_like('%Stephen%') );
    ut.expect( 'Stephen ' ).to_( be_like('Stephen^_', '^') ); --escape wildcards with '^'
    ut.expect( l_clob ).to_be_like('%stephen');
    ut.expect( l_clob ).to_be_like('%Stephe\_', '\'); --escape wildcards with '\'
    ut.expect( l_clob ).to_( be_like('%stephen') );
    ut.expect( l_clob ).to_( be_like('%Stephe\_', '\') ); --escape wildcards with '\'

    ut.expect( sysdate ).to_( be_like(sysdate) ); --case insensitive
    ut.expect( 12345 ).to_( be_like(12345) ); --case insensitive

  end;

  procedure demo_to_be_like_success is
    l_clob  clob := 'There was a guy named STEPHEN_';
  begin
    ut.expect( 'Hi, I am Stephen' ).to_be_like('%Stephen');
    ut.expect( 'stephen_' ).to_be_like('_tephen\_', '\'); --escape wildcards with '\'
    ut.expect( 'Hi, I am Stephen' ).to_( be_like('%Stephen') );
    ut.expect( 'stephen_' ).to_( be_like('_tephen^_', '^')); --escape wildcards with '^'
    ut.expect( l_clob ).to_be_like('%a%S_EP%');
    ut.expect( l_clob ).to_be_like('%a%S_EP%\_', '\'); --escape wildcards with '\'
    ut.expect( l_clob ).to_( be_like('%a%S_EP%') );
    ut.expect( l_clob ).to_( be_like('%a%S_EP%\_', '\') ); --escape wildcards with '\'
  end;

  procedure demo_not_to_failure is
  begin
    ut.expect( 'Hi, I am Stephen' ).not_to( be_like('%Stephen') );
    ut.expect( 'stephen' ).not_to( match('^Stephen$', 'i') ); --case insensitive
    ut.expect( sysdate ).not_to( be_not_null() );
    ut.expect( to_char(null) ).not_to( be_null() );
    ut.expect( false ).not_to( be_false );
    ut.expect( true ).not_to( be_true );
    ut.expect( 123 ).not_to( be_false );
    ut.expect( sysdate ).not_to( be_true );
    ut.expect( 1 ).not_to( equal( 1 ) );
    ut.expect( 1 ).not_to( equal( '1' ) );
    ut.expect( to_char(null) ).not_to( equal( to_char(null) ) );
  end;

  procedure demo_not_to_success is
  begin
    ut.expect( sysdate ).not_to( be_null() );
    ut.expect( to_char(null) ).not_to( be_not_null() );
    ut.expect( true ).not_to( be_false );
    ut.expect( false ).not_to( be_true );
    ut.expect(sysdate).not_to( be_between(sysdate+1,sysdate+2) );
    ut.expect( 1 ).not_to( equal( 2 ) );
    ut.expect( 'asd' ).not_to( be_like('z%q') );
  end;

end;
/
