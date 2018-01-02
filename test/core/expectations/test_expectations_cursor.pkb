create or replace package body test_expectations_cursor is

  procedure cleanup_expectations is
  begin
    ut3.ut_expectation_processor.clear_expectations();
  end;

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

  procedure with_temp_table
  as
    pragma autonomous_transaction;
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    -- Arrange
    execute immediate 'insert into gtt_test_table ( value ) values ( ''Test-entry'' )';
    open l_expected for select 'Test-entry' as value from dual;
    open l_actual for 'select * from gtt_test_table';
    --Act - execute the expectation on cursor opened on GTT
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
    --Cleanup
    rollback;
  end;


  procedure success_on_same_data
  as
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
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
    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
  end;

  procedure success_on_empty
  as
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    -- Arrange
    open l_expected for select * from dual where 1=0;
    open l_actual for select * from dual where 1=0;
    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
  end;

  procedure success_on_null
  as
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
  end;

  procedure fail_null_vs_empty
  as
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_expected for select * from dual where 1=0;
    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);
  end;

  procedure fail_on_difference
  as
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_expected for select to_clob('This is an even longer test clob') as my_clob from dual;
    open l_actual for select to_clob('Another totally different story') as my_clob from dual;
    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);
  end;

  procedure fail_on_expected_missing
  as
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_expected for select 1 as my_num from dual;
    open l_actual   for select 1 as my_num from dual union all select 1 as my_num from dual;
    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);
  end;

  procedure fail_on_actual_missing
  as
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_expected for select 1 as my_num from dual union all select 1 as my_num from dual;
    open l_actual   for select 1 as my_num from dual;
    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);
  end;

  procedure fail_on_different_column_name
  as
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
  --Arrange
    open l_expected for select 1 as col_1 from dual;
    open l_actual   for select 1 as col_2 from dual;
    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);
  end;


procedure fail_on_different_column_order
  as
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_expected for select 1 as col_1, 2 as col_2 from dual;
    open l_actual   for select 2 as col_2, 1 as col_1 from dual;
    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);
  end;

  procedure fail_on_different_row_order
  as
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_expected for select 1 as my_num from dual union all select 2 as my_num from dual;
    open l_actual   for select 2 as my_num from dual union all select 1 as my_num from dual;
    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);
  end;

  procedure ignore_time_part_of_date
  as
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
    l_date     date   := sysdate;
    l_second   number := 1/24/60/60;
  begin
    --Arrange
    ut.reset_nls;
    open l_actual for select l_date as some_date from dual;
    open l_expected for select l_date-l_second some_date from dual;
    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
  end;

  procedure include_time_in_date_with_nls
  as
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
    l_date     date   := sysdate;
    l_second   number := 1/24/60/60;
  begin
    --Arrange
    ut.set_nls;
    open l_actual for select l_date as some_date from dual;
    open l_expected for select l_date-l_second some_date from dual;
    ut.reset_nls;
    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);
  end;

  procedure exclude_columns_as_list
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select a.*, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col"  from all_objects a where rownum < 4;
    open l_expected for select a.*, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col"  from all_objects a where rownum < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected, a_exclude=>ut3.ut_varchar2_list('A_COLUMN','Some_Col'));
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
  end;

  procedure excludes_columns_as_csv
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select a.*, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col" from all_objects a where rownum < 4;
    open l_expected for select a.*, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col" from all_objects a where rownum < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected, a_exclude=>'A_COLUMN,Some_Col');
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
  end;

  procedure exclude_columns_xpath_invalid
  as
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_result   integer;
    e_xpath_error exception;
    pragma exception_init (e_xpath_error,-31011);
  begin
    --Arrange
    open l_actual   for select a.*, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col" from all_objects a where rownum < 4;
    open l_expected for select a.*, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col" from all_objects a where rownum < 4;
    begin
      --Act
      ut3.ut.expect(l_actual).to_equal(l_expected, a_exclude=>'/ROW/A_COLUMN,//Some_Col');
      --Assert
      ut.fail('Expected -31011 but nothing was raised');
    exception
      when e_xpath_error then
        ut.expect(sqlcode).to_equal(-31011);
    end;
  end;


  procedure exclude_columns_xpath
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col" from dual;
    open l_expected for select 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col" from dual;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected, a_exclude=>'/ROW/A_COLUMN|/ROW/Some_Col');
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
  end;


end;
/
