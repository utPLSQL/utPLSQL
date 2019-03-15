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
/