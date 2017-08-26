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
    c_expected sys_refcursor;
    c_actual sys_refcursor;
  begin

    -- Arrange
    execute immediate 'insert into gtt_test_table ( value ) values ( ''Test-entry'' )';

    open c_expected for select 'Test-entry' as value from dual;
    open c_actual for 'select * from gtt_test_table';
    
    --Act - execute the expectation on cursor opened on GTT
    ut3.ut.expect( c_actual ).to_equal( a_expected => c_expected );
    
    --Assert - check that expectation was executed successfully
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
    
    --Cleanup
    ut3.ut_expectation_processor.clear_expectations();

    rollback;
  end;
end;
/