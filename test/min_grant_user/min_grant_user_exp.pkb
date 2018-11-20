create or replace package body min_grant_user_exp is

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
