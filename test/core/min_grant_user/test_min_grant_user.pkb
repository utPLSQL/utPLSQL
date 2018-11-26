create or replace package body test_min_grant_user is

  procedure create_ut3$user#_tests is
    pragma autonomous_transaction;
  begin
    execute immediate q'[
      create or replace package ut3$user#.test_cursor_grants is
        --%suite()

        procedure run;

        --%test(execute join by test)
        procedure test_join_by_cursor;
      end;
      ]';
    execute immediate q'[
      create or replace package body ut3$user#.test_cursor_grants is
        procedure run is
        begin
          ut3.ut.run('test_cursor_grants');
        end;
        procedure test_join_by_cursor is
          l_actual   SYS_REFCURSOR;
          l_expected SYS_REFCURSOR;
        begin
          --Arrange
          open l_actual for select owner, object_name,object_type from all_objects where owner = user
          order by 1,2,3 asc;
          open l_expected for select owner, object_name,object_type from all_objects where owner = user
          order by 1,2,3 desc;

          --Act
          ut3.ut.expect(l_actual).to_equal(l_expected).join_by('OWNER');

        end;


      end;
      ]';
  end;

  procedure drop_ut3$user#_tests is
    pragma autonomous_transaction;
  begin
    execute immediate q'[drop package ut3$user#.test_cursor_grants]';
  end;



  procedure test_join_by_cursor is
    l_results clob;
  begin
    execute immediate 'begin ut3$user#.test_cursor_grants.run(); end;';
    l_results := core.get_dbms_output_as_clob();
    --Assert
    ut.expect( l_results ).to_be_like( '%execute join by test [% sec]' ||
    '%1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%' );

  end;
 
end;
/
