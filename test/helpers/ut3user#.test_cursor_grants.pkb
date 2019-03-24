create or replace package body ut3$user#.test_cursor_grants is

  procedure run_test_join_by_cursor is
  begin
    ut3.ut.run('test_cursor_grants.test_join_by_cursor');
  end;

  procedure run_test_equal_cursor is
  begin
    ut3.ut.run('test_cursor_grants.test_equal_cursor');
  end;
  
  procedure run_test_not_empty_cursor is
  begin
    ut3.ut.run('test_cursor_grants.test_not_empty_cursor');
  end;

  procedure run_test_have_count_cursor is
  begin
    ut3.ut.run('test_cursor_grants.test_have_count_cursor');
  end;
  
  procedure run_test_empty_cursor is  
  begin
    ut3.ut.run('test_cursor_grants.test_empty_cursor');
  end;
  
  procedure run_test_equal_non_diff_sql is  
  begin
    ut3.ut.run('test_cursor_grants.test_equal_non_diff_sql');
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
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('OBJECT_NAME,OBJECT_TYPE');

  end;
    
  procedure test_equal_cursor is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_list ut3_tester.test_dummy_object_list;
  begin
    --Arrange
    open l_actual for select value(x) as item from table(l_list) x;
    open l_expected for select value(x) as item from table(l_list) x;

    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected);

  end;
  
  procedure test_not_empty_cursor is
    l_details_cur SYS_REFCURSOR;
    l_expected         ut3_tester.test_dummy_object_list;
  begin
    select ut3_tester.test_dummy_object( rn, 'Something '||rn, rn1)
    bulk collect into l_expected
    from (select rownum * case when mod(rownum,2) = 0 then -1 else 1 end rn,
                rownum * case when mod(rownum,4) = 0 then -1 else 1 end rn1
         from dual connect by level <=10);
         
    --Arrange
    open l_details_cur for
      select value(x) as item from table(l_expected) x;
      
    --Act
    ut3.ut.expect(l_details_cur).not_to_be_empty();
  end;
    
  procedure test_have_count_cursor is
    l_expected SYS_REFCURSOR;
  begin
    --Arrange
    open l_expected for
      select value(x) as item from table(ut3_tester.test_dummy_object_list()) x;
      
    --Act
    ut3.ut.expect(l_expected).to_have_count(0);
  end;
  
  procedure test_empty_cursor is
    l_expected SYS_REFCURSOR;
  begin
    open l_expected for
      select value(x) as item from table(ut3_tester.test_dummy_object_list()) x;             
    --Act
    ut3.ut.expect(l_expected).to_be_empty();
  end;
  
  procedure test_equal_non_diff_sql is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
  begin
    open l_actual for
      select to_clob('test1') as item from dual;   

    open l_expected for
      select to_clob('test1') as item from dual;
      
    ut3.ut.expect(l_actual).to_equal(l_expected);   
  end;
  
end;
/
