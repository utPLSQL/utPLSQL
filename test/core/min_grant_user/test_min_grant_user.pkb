create or replace package body test_min_grant_user is

  procedure test_join_by_cursor is
    l_results clob;
  begin
    execute immediate 'begin ut3$user#.test_cursor_grants.run_test_join_by_cursor(); end;';
    l_results := core.get_dbms_output_as_clob();
    --Assert
    ut.expect( l_results ).to_be_like( '%execute join by test [% sec]' ||
    '%1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%' );

  end;
 
  procedure test_equal_cursor is
    l_results clob;
  begin
    execute immediate 'begin ut3$user#.test_cursor_grants.run_test_equal_cursor(); end;';
    l_results := core.get_dbms_output_as_clob();
    --Assert
    ut.expect( l_results ).to_be_like( '%execute equal test [% sec]' ||
    '%1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%' );

  end;
  
  procedure test_not_empty_cursor is
    l_results clob;
  begin
    execute immediate 'begin ut3$user#.test_cursor_grants.run_test_not_empty_cursor(); end;';
    l_results := core.get_dbms_output_as_clob();
    --Assert
    ut.expect( l_results ).to_be_like( '%execute not_empty test [% sec]' ||
    '%1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%' );

  end;


  procedure test_have_count_cursor is
    l_results clob;
  begin
    execute immediate 'begin ut3$user#.test_cursor_grants.run_test_have_count_cursor(); end;';
    l_results := core.get_dbms_output_as_clob();
    --Assert
    ut.expect( l_results ).to_be_like( '%execute have_count test [% sec]' ||
    '%1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%' );

  end;

  procedure test_empty_cursor is
    l_results clob;
  begin
    execute immediate 'begin ut3$user#.test_cursor_grants.run_test_empty_cursor(); end;';
    l_results := core.get_dbms_output_as_clob();
    --Assert
    ut.expect( l_results ).to_be_like( '%execute empty test [% sec]' ||
    '%1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%' );

  end;
  
end;
/
