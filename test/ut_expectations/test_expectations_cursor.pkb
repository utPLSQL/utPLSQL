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
    v_expected t_gtt_data_t;

    c_expected sys_refcursor;
    c_actual sys_refcursor;
  begin
      
    v_expected(1).value := 'Test-entry';

    -- insert test-data into temporary table
    execute immediate 'insert into gtt_test_table ( value ) values ( ''Test-entry'' )';

    -- test 
    open c_expected for select * from table(v_expected);
    open c_actual for 'select * from gtt_test_table';

    ut.expect( c_actual ).to_equal( a_expected => c_expected );

  end;
end;
/