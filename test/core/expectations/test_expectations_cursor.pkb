create or replace package body test_expectations_cursor is

  gc_blob      blob := to_blob('123');
  gc_clob      clob := to_clob('abc');
  gc_date      date := sysdate;
  gc_ds_int    interval day(9) to second(9) := numtodsinterval(1.12345678912, 'day');
  gc_num       number := 123456789.1234567890123456789;
  gc_ts        timestamp(9) := to_timestamp_tz('2017-03-30 00:21:12.123456789 cet','yyyy-mm-dd hh24:mi:ss.ff9 tzr');
  gc_ts_tz     timestamp(9) with time zone := to_timestamp_tz('2017-03-30 00:21:12.123456789 cet','yyyy-mm-dd hh24:mi:ss.ff9 tzr');
  gc_ts_ltz    timestamp(9) with local time zone := to_timestamp_tz('2017-03-30 00:21:12.123456789 cet','yyyy-mm-dd hh24:mi:ss.ff9 tzr');
  gc_varchar   varchar2(4000) := 'a varchar2';
  gc_ym_int    interval year(9) to month := numtoyminterval(1.1, 'year');

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

  procedure success_on_both_null
  as
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
  end;

  procedure success_is_null
  as
    l_actual   sys_refcursor;
  begin
    --Act
    ut3.ut.expect( l_actual ).to_be_null();
    ut3.ut.expect( l_actual ).not_to_be_not_null();
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
  end;

  procedure success_is_not_null
  as
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_actual for select * from dual;
    --Act
    ut3.ut.expect( l_actual ).not_to_be_null();
    ut3.ut.expect( l_actual ).to_be_not_null();
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
  end;

  procedure success_is_empty
  as
    l_actual   sys_refcursor;
  begin
  --Arrange
    open l_actual for select * from dual where 0=1;
    --Act
    ut3.ut.expect( l_actual ).to_be_empty();
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
  end;

  procedure success_is_not_empty
  as
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_actual for select * from dual;
    --Act
    ut3.ut.expect( l_actual ).not_to_be_empty();
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
  end;

  procedure failure_is_null
  as
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_actual for select * from dual;
    --Act
    ut3.ut.expect( l_actual ).to_be_null();
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);
  end;

  procedure failure_is_not_null
  as
    l_actual   sys_refcursor;
  begin
    --Act
    ut3.ut.expect( l_actual ).not_to_be_null();
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);
  end;

  procedure failure_is_empty
  as
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_actual for select * from dual;
    --Act
    ut3.ut.expect( l_actual ).to_be_empty();
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);
  end;

  procedure failure_is_not_empty
  as
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_actual for select * from dual where 0=1;
    --Act
    ut3.ut.expect( l_actual ).not_to_be_empty();
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);
  end;

  procedure fail_null_vs_empty
  as
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_expected for select * from dual where 1=0;
    --Act
    ut3.ut.expect( l_actual ).not_to_equal( l_expected );
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
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

  procedure uses_default_nls_for_date
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual for select sysdate as some_date from dual;
    open l_expected for select to_char(sysdate) some_date from dual;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected);
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
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
    l_error_code integer := -31011; --xpath_error
  begin
    --Arrange
    open l_actual   for select a.*, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col" from all_objects a where rownum < 4;
    open l_expected for select a.*, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col" from all_objects a where rownum < 4;
    begin
      --Act
      ut3.ut.expect(l_actual).to_equal(l_expected, a_exclude=>'/ROW/A_COLUMN,//Some_Col');
      --Assert
      ut.fail('Expected '||l_error_code||' but nothing was raised');
    exception
      when others then
        ut.expect(sqlcode).to_equal(l_error_code);
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

  procedure data_diff_on_failure
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_actual for select rownum rn from dual connect by level <=2;
    open l_expected for select rownum rn from dual connect by level <=3;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected);

    l_expected_message := q'[Actual:%
    (rows: 2, mismatched: 1)
 (refcursor)%
was expected to equal:%
    (rows: 3, mismatched: 1)
    row_no: 3     <ROW><RN>3</RN></ROW>
 (refcursor)%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure prepare_table
  as
    pragma autonomous_transaction;
  begin
    execute immediate
    'create table test_table_for_cursors (
    some_blob          blob,
    some_clob          clob,
    some_date          date,
    some_ds_interval   interval day(9) to second(9),
    some_nummber       number,
    some_timestamp     timestamp(9),
    some_timestamp_tz  timestamp(9) with time zone,
    some_timestamp_ltz timestamp(9) with local time zone,
    some_varchar2      varchar2(4000),
    some_ym_interval   interval year(9) to month
    )';
    execute immediate q'[
 insert into test_table_for_cursors
 values( :gc_blob, :gc_clob, :gc_date, :gc_ds_int, :gc_num, :gc_ts, :gc_ts_tz, :gc_ts_ltz, :gc_varchar, :gc_ym_int
 )
]' using gc_blob, gc_clob, gc_date, gc_ds_int, gc_num, gc_ts, gc_ts_tz, gc_ts_ltz, gc_varchar, gc_ym_int;
    commit;
  end;

  procedure cleanup_table
  as
    pragma autonomous_transaction;
  begin
    execute immediate 'drop table test_table_for_cursors';
  end;

  procedure compares_sql_and_plsql_types is
    l_expected  sys_refcursor;
    l_actual    sys_refcursor;
  begin
    --Arrange
    open l_expected for
    select  gc_blob some_blob,
            gc_clob some_clob,
            gc_date some_date,
            gc_ds_int some_ds_interval,
            gc_num some_nummber,
            gc_ts some_timestamp,
            gc_ts_tz some_timestamp_tz,
            gc_ts_ltz some_timestamp_ltz ,
            gc_varchar some_varchar2,
            gc_ym_int some_ym_interval
    from dual;
    open l_actual for q'[select * from test_table_for_cursors]';
    --Act
    ut3.ut.expect(l_expected).to_equal(l_actual);
    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
  end;

  procedure closes_cursor_after_use
  as
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_actual  for select 1 as value from dual;
    --Act
    ut3.ut.expect(l_actual).to_be_empty();
    --Assert
    ut.expect(l_actual%isopen).to_be_false();
  end;

  procedure closes_cursor_after_use_on_err
  as
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_actual  for select 1/0 as value from dual;
    --Act
    begin
      ut3.ut.expect(l_actual).to_be_empty();
    exception
      when others then
        null;
    end;
    --Assert
    ut.expect(l_actual%isopen).to_be_false();
  end;

  procedure reports_on_exception_in_cursor
  as
    l_actual     sys_refcursor;
    l_error_code integer := -19202; --Error occurred in XML processing
  begin
    --Act
    open l_actual for select 1/0 as error_column from dual connect by level < 10;
    begin
      ut3.ut.expect(l_actual).to_be_empty();
      --Assert
      ut.fail('Expected '||l_error_code||' but nothing was raised');
    exception
      when others then
        ut.expect(sqlcode).to_equal(l_error_code);
    end;
  end;

  procedure reports_on_closed_cursor
  as
    l_actual     sys_refcursor;
    l_error_code integer := -19202; --Error occurred in XML processing
  begin
    --Act
    open l_actual for select 1 as value from dual connect by level < 10;
    close l_actual;
    begin
      ut3.ut.expect(l_actual).to_be_empty();
      --Assert
      ut.fail('Expected '||l_error_code||' but nothing was raised');
      exception
      when others then
      ut.expect(sqlcode).to_equal(l_error_code);
    end;
  end;

  procedure compares_over_1000_rows
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual for select object_name from all_objects where rownum <=1100;
    open l_expected for select object_name from all_objects where rownum <=1100;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected);

    --Assert
    ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);
  end;

end;
/
