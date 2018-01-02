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
    l_expected sys_refcursor;
    l_actual sys_refcursor;
  begin
    
    -- Arrange
    open l_expected for
    select 1 as my_num,
           'This is my test string' as my_string,
           to_clob('This is an even longer test clob') as my_clob,
           to_date('1984-09-05', 'YYYY-MM-DD') as my_date
    from dual;

    open l_actual for
    select 1 as my_num,
           'This is my test string' as my_string,
           to_clob('This is an even longer test clob') as my_clob,
           to_date('1984-09-05', 'YYYY-MM-DD') as my_date
    from dual;

    --Act - execute the expectation on cursor opened on GTT
    ut3.ut.expect( l_actual ).to_equal( l_expected );

    --Assert - check that expectation was executed successfully
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);

    --Cleanup
    ut3.ut_expectation_processor.clear_expectations();

  end;

  procedure test_cursor_success_on_empty
  as
    l_expected sys_refcursor;
    l_actual sys_refcursor;
  begin
    
    -- Arrange
    open l_expected for select * from dual where 1=0;
    open l_actual for select * from dual where 1=0;

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
    l_expected sys_refcursor;
    l_actual sys_refcursor;
  begin
    
    -- Arrange
    open l_expected for select to_clob('This is an even longer test clob') as my_clob from dual;
    open l_actual for select to_clob('Another totally different story') as my_clob from dual;

    --Act - execute the expectation on cursor opened on GTT
    ut3.ut.expect( l_actual ).to_equal( l_expected );

    --Assert - check that expectation was executed successfully
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);

    --Cleanup
    ut3.ut_expectation_processor.clear_expectations();

  end;

  procedure fail_on_expected_missing
  as
    l_expected sys_refcursor;
    l_actual sys_refcursor;
  begin
    
    -- Arrange
    open l_expected for select 1 as my_num from dual;
    open l_actual   for select 1 as my_num from dual union all select 1 as my_num from dual;

    --Act - execute the expectation on cursor opened on GTT
    ut3.ut.expect( l_actual ).to_equal( l_expected );

    --Assert - check that expectation was executed successfully
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);

    --Cleanup
    ut3.ut_expectation_processor.clear_expectations();

  end;

  procedure fail_on_actual_missing
  as
    l_expected sys_refcursor;
    l_actual sys_refcursor;
  begin
    
    -- Arrange
    open l_expected for select 1 as my_num from dual union all select 1 as my_num from dual;
    open l_actual   for select 1 as my_num from dual;

    --Act - execute the expectation on cursor opened on GTT
    ut3.ut.expect( l_actual ).to_equal( l_expected );

    --Assert - check that expectation was executed successfully
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);

    --Cleanup
    ut3.ut_expectation_processor.clear_expectations();

  end;
end;
/
