create or replace package body test_expectations_cursor is

  procedure setup_temp_table_test
  as
    pragma autonomous_transaction;
  begin
    execute immediate 'create global temporary table gtt_test_table (
        value varchar2(250)
      ) on commit delete rows';

  end;

  procedure cleanup_temp_table_test
  as
    pragma autonomous_transaction;
  begin
    execute immediate 'drop table gtt_test_table';
  end;

  /** Just returns a pre-made expected object
  */
  function get_expected_obj return t_test_table
  as
    l_expected_obj t_test_table;
  begin
    
    l_expected_obj(1).my_num := 1;
    l_expected_obj(1).my_string := 'This is my test string';
    l_expected_obj(1).my_clob := 'This is an even longer test clob';
    l_expected_obj(1).my_date := to_date('1984-09-05', 'YYYY-MM-DD');

    return l_expected_obj;
  end;

  procedure test_cursor_w_temp_table
  as
    pragma autonomous_transaction;
    l_expected sys_refcursor;
    l_actual sys_refcursor;
  begin

    -- Arrange
    execute immediate 'insert into gtt_test_table ( value ) values ( ''Test-entry'' )';

    open l_expected for select 'Test-entry' as value from dual;
    open l_actual for 'select * from gtt_test_table';

    --Act - execute the expectation on cursor opened on GTT
    ut3.ut.expect( l_actual ).to_equal( l_expected );

    --Assert - check that expectation was executed successfully
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);

    --Cleanup
    ut3.ut_expectation_processor.clear_expectations();

    rollback;
  end;


  procedure test_cursor_success
  as
    l_expected_obj t_test_table;
    l_actual_obj t_test_table;
    l_expected sys_refcursor;
    l_actual sys_refcursor;
  begin
    
    -- Arrange
    l_expected_obj := get_expected_obj();
    l_actual_obj := get_expected_obj();

    open l_expected for select * from table(l_expected_obj);
    open l_actual for select * from table(l_actual_obj);

    --Act - execute the expectation on cursor opened on GTT
    ut3.ut.expect( l_actual ).to_equal( l_expected );

    --Assert - check that expectation was executed successfully
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);

    --Cleanup
    ut3.ut_expectation_processor.clear_expectations();

  end;

  --%test(Test cursor comparison success when both empty)
  procedure test_cursor_success_on_empty
  as
    l_expected_obj t_test_table;
    l_actual_obj t_test_table;
    l_expected sys_refcursor;
    l_actual sys_refcursor;
  begin
    
    -- Arrange
    open l_expected for select * from table(l_expected_obj);
    open l_actual for select * from table(l_actual_obj);

    --Act - execute the expectation on cursor opened on GTT
    ut3.ut.expect( l_actual ).to_equal( l_expected );

    --Assert - check that expectation was executed successfully
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);

    --Cleanup
    ut3.ut_expectation_processor.clear_expectations();

  end;

  --%test(Test cursor comparison fails on different content)
  procedure test_cursor_fail_on_difference
  as
    l_expected_obj t_test_table;
    l_actual_obj t_test_table;
    l_expected sys_refcursor;
    l_actual sys_refcursor;
  begin
    
    -- Arrange
    l_expected_obj := get_expected_obj();
    l_actual_obj := get_expected_obj();
    l_actual_obj(1).my_clob := 'Another totally different story';

    open l_expected for select * from table(l_expected_obj);
    open l_actual for select * from table(l_actual_obj);
      
    --Act - execute the expectation on cursor opened on GTT
    ut3.ut.expect( l_actual ).to_equal( l_expected );

    --Assert - check that expectation was executed successfully
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);

    --Cleanup
    ut3.ut_expectation_processor.clear_expectations();

  end;

  procedure test_cursor_fail_on_expected_missing
  as
    l_expected_obj t_test_table;
    l_actual_obj t_test_table;
    l_expected sys_refcursor;
    l_actual sys_refcursor;
  begin
    
    -- Arrange
    l_expected_obj := get_expected_obj();
    l_actual_obj := get_expected_obj();
    l_actual_obj(2).my_num := 2;

    open l_expected for select * from table(l_expected_obj);
    open l_actual for select * from table(l_actual_obj);
      
    --Act - execute the expectation on cursor opened on GTT
    ut3.ut.expect( l_actual ).to_equal( l_expected );

    --Assert - check that expectation was executed successfully
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);

    --Cleanup
    ut3.ut_expectation_processor.clear_expectations();

  end;

  procedure test_cursor_fail_on_actual_missing
  as
    l_expected_obj t_test_table;
    l_actual_obj t_test_table;
    l_expected sys_refcursor;
    l_actual sys_refcursor;
  begin
    
    -- Arrange
    l_expected_obj := get_expected_obj();
    l_expected_obj(2).my_num := 2;
    l_actual_obj := get_expected_obj();

    open l_expected for select * from table(l_expected_obj);
    open l_actual for select * from table(l_actual_obj);
      
    --Act - execute the expectation on cursor opened on GTT
    ut3.ut.expect( l_actual ).to_equal( l_expected );

    --Assert - check that expectation was executed successfully
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);

    --Cleanup
    ut3.ut_expectation_processor.clear_expectations();

  end;
end;
/
