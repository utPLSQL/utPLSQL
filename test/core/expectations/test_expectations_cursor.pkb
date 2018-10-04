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
    expectations.cleanup_expectations( );
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
    execute immediate 'insert into gtt_test_table ( value ) ' ||
                      'select  ''Test-entry'' from dual union all ' ||
                      'select  ''Other test entry'' from dual';
    open l_expected for
      select 'Test-entry' as value from dual union all
      select 'Other test entry' as value from dual;
    open l_actual for 'select * from gtt_test_table';
    --Act - execute the expectation on cursor opened on GTT
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
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
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
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
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure success_on_both_null
  as
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure success_to_be_null
  as
    l_actual   sys_refcursor;
  begin
    --Act
    ut3.ut.expect( l_actual ).to_be_null();
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure success_not_to_be_not_null
  as
    l_actual   sys_refcursor;
  begin
    --Act
    ut3.ut.expect( l_actual ).not_to_be_not_null();
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure success_not_to_be_null
  as
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_actual for select * from dual;
    --Act
    ut3.ut.expect( l_actual ).to_be_not_null();
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure success_to_be_not_null
  as
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_actual for select * from dual;
    --Act
    ut3.ut.expect( l_actual ).to_be_not_null();
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
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
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
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
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
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
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure failure_is_not_null
  as
    l_actual   sys_refcursor;
  begin
    --Act
    ut3.ut.expect( l_actual ).not_to_be_null();
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
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
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
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
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
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
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
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
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
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
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
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
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
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
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
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
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
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
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure include_time_in_date_with_nls
  as
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
    l_date     date   := sysdate;
    l_second   number := 1/24/60/60;
  begin
    --Arrange
    ut3.ut.set_nls;
    open l_actual for select l_date as some_date from dual;
    open l_expected for select l_date-l_second some_date from dual;
    ut3.ut.reset_nls;
    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure uses_default_nls_for_date
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select sysdate as some_date from dual;
    open l_expected for select to_date(to_char(sysdate)) as some_date from dual;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected);
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure exclude_columns_as_list
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col"  from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col"  from dual a connect by level < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected, a_exclude=>ut3.ut_varchar2_list('A_COLUMN','Some_Col'));
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure exclude_columns_as_csv
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col" from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col" from dual a connect by level < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected, a_exclude=>'A_COLUMN,Some_Col');
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure exclude_columns_as_mixed_list is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col"  from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col"  from dual a connect by level < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected, a_exclude=>ut3.ut_varchar2_list('A_COLUMN','/ROW/Some_Col'));
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure exclude_columns_as_mix_csv_lst is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    begin
      --Arrange
      open l_actual   for select rownum as rn, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col"  from dual a connect by level < 4;
      open l_expected for select rownum as rn, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col"  from dual a connect by level < 4;
      --Act
      ut3.ut.expect(l_actual).to_equal(l_expected, a_exclude=>'A_COLUMN,/ROW/Some_Col');
      --Assert
      ut.expect(expectations.failed_expectations_data()).to_be_empty();
    end;

  procedure exclude_columns_xpath_invalid
  as
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_error_code integer := -31011; --xpath_error
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col" from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col" from dual a connect by level < 4;
    begin
      --Act
      ut3.ut.expect(l_actual).to_equal(l_expected, a_exclude=>'/ROW/A_COLUMN,\\//Some_Col');
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
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure exclude_ignores_invalid_column
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'c' as A_COLUMN from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'd' as A_COLUMN from dual a connect by level < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected, a_exclude=>ut3.ut_varchar2_list('A_COLUMN','non_existing_column'));
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure include_columns_as_list
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col"  from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col"  from dual a connect by level < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).include(ut3.ut_varchar2_list('RN','//A_Column','SOME_COL'));
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure include_columns_as_csv
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col" from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col" from dual a connect by level < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).include('RN,//A_Column,SOME_COL');
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure include_columns_xpath_invalid
  as
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col" from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col" from dual a connect by level < 4;
    begin
      --Act
      ut3.ut.expect(l_actual).to_equal(l_expected).include('/ROW/RN,\\//A_Column,//SOME_COL');
      --Assert
      ut.fail('Expected exception but nothing was raised');
    exception
      when others then
        ut.expect(sqlcode).to_be_between(-31013,-31011);
    end;
  end;

  procedure include_columns_xpath
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col" from dual connect by level < 4;
    open l_expected for select rownum as rn, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col" from dual connect by level < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).include('/ROW/RN|//A_Column|//SOME_COL');
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure include_ignores_invalid_column
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'c' as A_COLUMN from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'd' as A_COLUMN from dual a connect by level < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).include(ut3.ut_varchar2_list('RN','non_existing_column'));
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure include_exclude_col_csv_xpath
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col" from dual connect by level < 4;
    open l_expected for select rownum as rn, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col" from dual connect by level < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).exclude('Some_Col').include('/ROW/RN|//Some_Col');
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure include_exclude_columns_list
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col" from dual connect by level < 4;
    open l_expected for select rownum as rn, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col" from dual connect by level < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).exclude(ut3.ut_varchar2_list('A_COLUMN')).include(ut3.ut_varchar2_list('RN','A_Column','A_COLUMN'));
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure data_diff_on_rows_mismatch
  as
    l_actual           sys_refcursor;
    l_expected         sys_refcursor;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_actual   for select 1 rn from dual union all select 6 rn from dual;
    open l_expected for select rownum rn from dual connect by level <=3;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected);

    l_expected_message := q'[Actual: refcursor [ count = 2 ] was expected to equal: refcursor [ count = 3 ]
Diff:
Rows: [ 2 differences ]
  Row No. 2 - Actual:   <RN>6</RN>
  Row No. 2 - Expected: <RN>2</RN>
  Row No. 3 - Missing:  <RN>3</RN>]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure char_and_varchar2_col_is_equal is
    l_expected         sys_refcursor;
    l_actual           sys_refcursor;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_actual   for select cast('a' as char(1))      a_column, 1 as id from dual;
    open l_expected for select cast('a' as varchar2(10)) a_column          from dual;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected);
    l_expected_message := q'[Actual: refcursor [ count = 1 ] was expected to equal: refcursor [ count = 1 ]
Diff:
Columns:
  Column <ID> [position: 2, data-type: NUMBER] is not expected in results.
Rows: [ 1 differences ]
  All rows are different as the columns are not matching.]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure column_diff_on_data_type_diff is
    l_actual           sys_refcursor;
    l_expected         sys_refcursor;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_actual   for select to_char(rownum) rn, rownum another_rn from dual connect by level <=2;
    open l_expected for select rownum rn,          rownum another_rn from dual connect by level <=2;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected);

    l_expected_message := q'[Actual: refcursor [ count = 2 ] was expected to equal: refcursor [ count = 2 ]
Diff:
Columns:
  Column <RN> data-type is invalid. Expected: NUMBER, actual: VARCHAR2.]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure column_diff_on_col_name_diff is
    l_actual           sys_refcursor;
    l_expected         sys_refcursor;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_actual   for select rownum rn, rownum bad_column_name      from dual connect by level <=2;
    open l_expected for select rownum rn, rownum expected_column_name from dual connect by level <=2;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected);

    l_expected_message := q'[Actual: refcursor [ count = 2 ] was expected to equal: refcursor [ count = 2 ]
Diff:
Columns:%
  Column <EXPECTED_COLUMN_NAME> [data-type: NUMBER] is missing. Expected column position: 2.%
  Column <BAD_COLUMN_NAME> [position: 2, data-type: NUMBER] is not expected in results.%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  --%test(Reports column diff on cusror with different column positions)
  procedure column_diff_on_col_position is
    l_actual           sys_refcursor;
    l_expected         sys_refcursor;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_actual   for select rownum+1 col_1, rownum+2 col_2, rownum+3 col_3, rownum+4 col_4 from dual connect by level <=2;
    open l_expected for select rownum+1 col_1, rownum+4 col_4, rownum+2 col_2, rownum+3 col_3 from dual connect by level <=2;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected);

    l_expected_message := q'[Actual: refcursor [ count = 2 ] was expected to equal: refcursor [ count = 2 ]
Diff:
Columns:
  Column <COL_4> is misplaced. Expected position: 2, actual position: 4.
  Column <COL_2> is misplaced. Expected position: 3, actual position: 2.
  Column <COL_3> is misplaced. Expected position: 4, actual position: 3.
Rows: [ 2 differences ]
  All rows are different as the columns are not matching.]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;


  --%test(Reports only mismatched columns on column data mismatch)
  procedure data_diff_on_col_data_mismatch is
    l_actual           sys_refcursor;
    l_expected         sys_refcursor;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_actual   for select rownum good_col, -rownum bad_col from dual connect by level <=2;
    open l_expected for select rownum good_col,  rownum bad_col from dual connect by level <=2;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected);

    l_expected_message := q'[Actual: refcursor [ count = 2 ] was expected to equal: refcursor [ count = 2 ]
Diff:
Rows: [ 2 differences ]
  Row No. 1 - Actual:   <BAD_COL>-1</BAD_COL>
  Row No. 1 - Expected: <BAD_COL>1</BAD_COL>
  Row No. 2 - Actual:   <BAD_COL>-2</BAD_COL>
  Row No. 2 - Expected: <BAD_COL>2</BAD_COL>]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure data_diff_on_20_rows_only is
    l_actual           sys_refcursor;
    l_expected         sys_refcursor;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_actual for
      select rownum
            * case when mod(rownum,2) = 0 then -1 else 1 end bad_col,
            rownum good_col
       from dual connect by level <=100;
    open l_expected for select rownum bad_col, rownum good_col from dual connect by level <=110;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected);

    l_expected_message := q'[Actual: refcursor [ count = 100 ] was expected to equal: refcursor [ count = 110 ]
Diff:
Rows: [ 60 differences, showing first 20 ]
  Row No. 2 - Actual:   <BAD_COL>-2</BAD_COL>
  Row No. 2 - Expected: <BAD_COL>2</BAD_COL>
  Row No. 4 - Actual:   <BAD_COL>-4</BAD_COL>
  Row No. 4 - Expected: <BAD_COL>4</BAD_COL>
  Row No. 6 - Actual:   <BAD_COL>-6</BAD_COL>
  Row No. 6 - Expected: <BAD_COL>6</BAD_COL>
  Row No. 8 - Actual:   <BAD_COL>-8</BAD_COL>
  Row No. 8 - Expected: <BAD_COL>8</BAD_COL>
  %
  Row No. 38 - Actual:   <BAD_COL>-38</BAD_COL>
  Row No. 38 - Expected: <BAD_COL>38</BAD_COL>
  Row No. 40 - Actual:   <BAD_COL>-40</BAD_COL>
  Row No. 40 - Expected: <BAD_COL>40</BAD_COL>]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure column_and_data_diff is
    l_actual           sys_refcursor;
    l_expected         sys_refcursor;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_expected for
      select 1 as ID, 'JACK' as FIRST_NAME, 'SPARROW' AS LAST_NAME, 10000 AS SALARY from dual union all
      select 2 as ID, 'LUKE' as FIRST_NAME, 'SKYWALKER' AS LAST_NAME, 1000 AS SALARY from dual union all
      select 3 as ID, 'TONY' as FIRST_NAME, 'STARK' AS LAST_NAME, 100000 AS SALARY from dual;
    open l_actual for
      select 'M' AS GENDER, 'JACK' as FIRST_NAME, 'SPARROW' AS LAST_NAME, 1 as ID, '25000' AS SALARY from dual union all
      select 'M' AS GENDER, 'TONY' as FIRST_NAME, 'STARK' AS LAST_NAME, 3 as ID, '100000' AS SALARY from dual union all
      select 'F' AS GENDER, 'JESSICA' as FIRST_NAME, 'JONES' AS LAST_NAME, 4 as ID, '2345' AS SALARY from dual union all
      select 'M' AS GENDER, 'LUKE' as FIRST_NAME, 'SKYWALKER' AS LAST_NAME, 2 as ID, '1000' AS SALARY from dual;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected);
    l_expected_message := q'[Actual: refcursor [ count = 4 ] was expected to equal: refcursor [ count = 3 ]
Diff:
Columns:
  Column <ID> is misplaced. Expected position: 1, actual position: 4.
  Column <SALARY> data-type is invalid. Expected: NUMBER, actual: VARCHAR2.
  Column <GENDER> [position: 1, data-type: CHAR] is not expected in results.
Rows: [ 4 differences ]
  Row No. 1 - Actual:   <SALARY>25000</SALARY>
  Row No. 1 - Expected: <SALARY>10000</SALARY>
  Row No. 2 - Actual:   <FIRST_NAME>TONY</FIRST_NAME><LAST_NAME>STARK</LAST_NAME><ID>3</ID><SALARY>100000</SALARY>
  Row No. 2 - Expected: <ID>2</ID><FIRST_NAME>LUKE</FIRST_NAME><LAST_NAME>SKYWALKER</LAST_NAME><SALARY>1000</SALARY>
  Row No. 3 - Actual:   <FIRST_NAME>JESSICA</FIRST_NAME><LAST_NAME>JONES</LAST_NAME><ID>4</ID><SALARY>2345</SALARY>
  Row No. 3 - Expected: <ID>3</ID><FIRST_NAME>TONY</FIRST_NAME><LAST_NAME>STARK</LAST_NAME><SALARY>100000</SALARY>
  Row No. 4 - Extra:    <GENDER>M</GENDER><FIRST_NAME>LUKE</FIRST_NAME><LAST_NAME>SKYWALKER</LAST_NAME><ID>2</ID><SALARY>1000</SALARY>]';
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
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
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

  procedure exception_when_closed_cursor
  is
    l_actual sys_refcursor;
    l_error_code constant integer := -20155;
  begin
    --Arrange
    open l_actual for select * from dual;
    close l_actual;
    --Act
    ut3.ut.expect( l_actual ).not_to_be_null;
  exception
    when others then
        --Assert
        ut.expect(sqlcode).to_equal(l_error_code);
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
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  function get_cursor return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for select rownum as rn, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col" from dual a connect by level < 4;
    return l_cursor;
  end;

  procedure deprec_to_equal_excl_varch is
  begin
    --Act
    ut3.ut.expect(get_cursor()).to_equal(get_cursor(), a_exclude => 'A_COLUMN,Some_Col');
    --Assert
    ut.expect(cardinality(ut3.ut_expectation_processor.get_warnings())).to_equal(1);
    ut.expect(ut3.ut_expectation_processor.get_warnings()(1)).to_be_like('The syntax: "%" is deprecated.%');
  end;

  procedure deprec_to_equal_excl_list is
  begin
    --Act
    ut3.ut.expect(get_cursor()).to_equal(get_cursor(), a_exclude => ut3.ut_varchar2_list('A_COLUMN','Some_Col'));
    --Assert
    ut.expect(cardinality(ut3.ut_expectation_processor.get_warnings())).to_equal(1);
    ut.expect(ut3.ut_expectation_processor.get_warnings()(1)).to_be_like('The syntax: "%" is deprecated.%');
  end;

  procedure deprec_not_to_equal_excl_varch is
  begin
    --Act
    ut3.ut.expect(get_cursor()).not_to_equal(get_cursor(), a_exclude => 'A_COLUMN,Some_Col');
    --Assert
    ut.expect(cardinality(ut3.ut_expectation_processor.get_warnings())).to_equal(1);
    ut.expect(ut3.ut_expectation_processor.get_warnings()(1)).to_be_like('The syntax: "%" is deprecated.%');
  end;

  procedure deprec_not_to_equal_excl_list is
  begin
    --Act
    ut3.ut.expect(get_cursor()).not_to_equal(get_cursor(), a_exclude => ut3.ut_varchar2_list('A_COLUMN','Some_Col'));
    --Assert
    ut.expect(cardinality(ut3.ut_expectation_processor.get_warnings())).to_equal(1);
    ut.expect(ut3.ut_expectation_processor.get_warnings()(1)).to_be_like('The syntax: "%" is deprecated.%');
  end;

  procedure deprec_equal_excl_varch is
  begin
    --Act
    ut3.ut.expect(get_cursor()).to_(ut3.equal(get_cursor(), a_exclude => 'A_COLUMN,Some_Col'));
    --Assert
    ut.expect(cardinality(ut3.ut_expectation_processor.get_warnings())).to_equal(1);
    ut.expect(ut3.ut_expectation_processor.get_warnings()(1)).to_be_like('The syntax: "%" is deprecated.%');
  end;

  procedure deprec_equal_excl_list is
  begin
    --Act
    ut3.ut.expect(get_cursor()).to_(ut3.equal(get_cursor(), a_exclude => ut3.ut_varchar2_list('A_COLUMN','Some_Col')));
    --Assert
    ut.expect(cardinality(ut3.ut_expectation_processor.get_warnings())).to_equal(1);
    ut.expect(ut3.ut_expectation_processor.get_warnings()(1)).to_be_like('The syntax: "%" is deprecated.%');
  end;

  procedure col_diff_on_col_name_implicit is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_actual   for select '1' , '2'      from dual connect by level <=2;
    open l_expected for select rownum , rownum expected_column_name from dual connect by level <=2;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected);

    l_expected_message := q'[Actual: refcursor [ count = 2 ] was expected to equal: refcursor [ count = 2 ]%
Diff:%
Columns:%
  Column <ROWNUM> [data-type: NUMBER] is missing. Expected column position: 1.%
  Column <EXPECTED_COLUMN_NAME> [data-type: NUMBER] is missing. Expected column position: 2.%
  Column <%1%> [position: 1, data-type: CHAR] is not expected in results.%
  Column <%2%> [position: 2, data-type: CHAR] is not expected in results.%
Rows: [ 2 differences ]%
  All rows are different as the columns are not matching.%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure col_mtch_on_col_name_implicit is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_actual   for select '1' , rownum  from dual connect by level <=2;
    open l_expected for select '1' , rownum  from dual connect by level <=2;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected);
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;
    
    
  procedure include_col_name_implicit is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'a', 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col" from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'a', 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col" from dual a connect by level < 4;
    begin
      --Act
      ut3.ut.expect(l_actual).to_equal(l_expected).include(q'!/ROW/RN,'a',//SOME_COL!');
      --Assert
      ut.fail('Expected exception but nothing was raised');
    exception
      when others then
        ut.expect(sqlcode).to_be_between(-31013,-31011);
    end;
  end;

  procedure exclude_col_name_implicit is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'a', 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col" from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'a', 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col" from dual a connect by level < 4;
    begin
      --Act
      ut3.ut.expect(l_actual).to_equal(l_expected).exclude(q'!/ROW/RN,'a',//SOME_COL!');
      --Assert
      ut.fail('Expected exception but nothing was raised');
    exception
      when others then
        ut.expect(sqlcode).to_be_between(-31013,-31011);
    end;
  end;
  
  procedure cursor_unorderd_compr_success is 
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
  begin
    --Arrange
    open l_actual for select username , user_id  from all_users order by username asc;
    open l_expected for select username , user_id  from all_users order by username desc;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).unordered;
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;
  
  procedure cursor_unordered_compare_fail is 
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
     open l_actual for select 'test1' username,-100 user_id from dual
                       union all
                       select 'test' username,-666 user_id from dual
                       order by 1 asc;

      open l_expected for select 'test1' username,-100 user_id from dual
                          union all
                          select 'test' username,-667 user_id from dual
                          order by 1 desc;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).unordered;
    l_expected_message := q'[%Actual: refcursor [ count = 2 ] was expected to equal: refcursor [ count = 2 ]%
%Diff:%
%Rows: [ 2 differences ]%
%Extra:    <ROW><USERNAME>test</USERNAME><USER_ID>-666</USER_ID></ROW>%
%Missing:  <ROW><USERNAME>test</USERNAME><USER_ID>-667</USER_ID></ROW>%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
  
  procedure cursor_joinby_compare is
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
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure cursor_joinby_compare_twocols is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
  begin
    --Arrange
    open l_actual for select owner, object_name,object_type from all_objects where owner = user
    order by 1,2,3 asc;
    open l_expected for select owner, object_name,object_type from all_objects where owner = user
    order by 1,2,3 desc;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by(ut3.ut_varchar2_list('OWNER,OBJECT_NAME'));
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;
 
   procedure cursor_joinby_compare_nokey is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'x' SOME_COL  from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'x' SOME_COL  from dual a connect by level < 4;
     
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('OWNER');
    --Assert
 l_expected_message := q'[%Actual: refcursor [ count = 3 ] was expected to equal: refcursor [ count = 3 ]%
Diff:%
%Unable to join sets:%
%Join key OWNER does not exists in expected%
%Join key OWNER does not exists in actual%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
  
  procedure cur_joinby_comp_twocols_nokey is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'x' SOME_COL  from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'x' SOME_COL  from dual a connect by level < 4;
     
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by(ut3.ut_varchar2_list('OWNER,USER_ID'));
    --Assert
 l_expected_message := q'[%Actual: refcursor [ count = 3 ] was expected to equal: refcursor [ count = 3 ]%
Diff:%
%Unable to join sets:%
%Join key OWNER does not exists in expected%
%Join key USER_ID does not exists in expected%
%Join key OWNER does not exists in actual%
%Join key USER_ID does not exists in actual%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
  
  procedure cursor_joinby_compare_exkey is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'x' SOME_COL  from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'x' SOME_COL  from dual a connect by level < 4;
     
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('SOME_COL').exclude('SOME_COL');
    --Assert
 l_expected_message := q'[%Actual: refcursor [ count = 3 ] was expected to equal: refcursor [ count = 3 ]%
Diff:%
%Unable to join sets:%
%Join key SOME_COL does not exists in expected%
%Join key SOME_COL does not exists in actual%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
  
  procedure cur_joinby_comp_twocols_exkey is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'x' SOME_COL  from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'x' SOME_COL  from dual a connect by level < 4;
     
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by(ut3.ut_varchar2_list('RN,SOME_COL')).exclude('RN');
    --Assert
 l_expected_message := q'[%Actual: refcursor [ count = 3 ] was expected to equal: refcursor [ count = 3 ]%
Diff:%
%Unable to join sets:%
%Join key RN does not exists in expected%
%Join key RN does not exists in actual%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
 
  procedure cursor_joinby_comp_nokey_ex is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_actual   for select rownum as rni, 'x' SOME_COL  from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'x' SOME_COL  from dual a connect by level < 4;
     
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('RNI');
    --Assert
 l_expected_message := q'[%Actual: refcursor [ count = 3 ] was expected to equal: refcursor [ count = 3 ]%
Diff:%
%Unable to join sets:%
%Join key RNI does not exists in expected%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
  
  procedure cursor_joinby_comp_nokey_ac is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'x' SOME_COL  from dual a connect by level < 4;
    open l_expected for select rownum as rni, 'x' SOME_COL  from dual a connect by level < 4;
     
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('RNI');
    --Assert
 l_expected_message := q'[%Actual: refcursor [ count = 3 ] was expected to equal: refcursor [ count = 3 ]%
Diff:%
%Unable to join sets:%
%Join key RNI does not exists in actual%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
 
  procedure cursor_joinby_compare_1000 is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
  begin
    --Arrange
    open l_actual for select object_name from all_objects where rownum <=1100;
    open l_expected for select object_name from all_objects where rownum <=1100;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('OBJECT_NAME');
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;
 
  procedure comp_bad_over_1000_rows is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
  begin
    --Arrange
    open l_actual for select object_name from all_objects where rownum <=1100;
    open l_expected for select object_name||'R' as object_name from all_objects where rownum <=1100;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('OBJECT_NAME');
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;
 
  procedure cursor_joinby_comp_bad_1000 is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
  begin
    --Arrange
    open l_actual for select object_name from all_objects where rownum <=1100;
    open l_expected for select object_name||'R' as object_name from all_objects where rownum <=1100;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('OBJECT_NAME');
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure cursor_joinby_comp_10000 is
     l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
  begin
    --Arrange
    open l_actual for select object_name from all_objects where rownum <=11000;
    open l_expected for select object_name from all_objects where rownum <=11000;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('OBJECT_NAME');
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;
  
  procedure cursor_joinby_compare_fail is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_expected for select username, user_id from all_users union all
    select 'TEST' username, -600 user_id from dual order by 1 desc;
    
    open l_actual for select username, user_id from all_users union all
    select 'TEST' username, -610 user_id from dual order by 1 asc;
     
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('USERNAME');
    --Assert
 l_expected_message := q'[%Actual: refcursor [ count = % ] was expected to equal: refcursor [ count = % ]
%Diff:%
%Rows: [ 1 differences ]%
%PK <USERNAME>TEST</USERNAME> - Actual:%<USER_ID>-610</USER_ID>%
%PK <USERNAME>TEST</USERNAME> - Expected:%<USER_ID>-600</USER_ID>%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
  
  procedure cursor_joinby_cmp_twocol_fail is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_expected for select username, user_id from all_users union all
    select 'TEST' username, -600 user_id from dual order by 1 desc;
    
    open l_actual for select username, user_id from all_users union all
    select 'TEST' username, -610 user_id from dual order by 1 asc;
     
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by(ut3.ut_varchar2_list('USERNAME,USER_ID'));
    --Assert
 l_expected_message := q'[%Actual: refcursor [ count = % ] was expected to equal: refcursor [ count = % ]
%Diff:%
%Rows: [ 2 differences ]%
%PK <USERNAME>TEST</USERNAME><USER_ID>-610</USER_ID> - Extra%
%PK <USERNAME>TEST</USERNAME><USER_ID>-600</USER_ID> - Missing%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
  
  procedure cur_joinby_cmp_threcol_fail is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_expected for select username, user_id,'Y' is_valid from all_users union all
    select 'TEST' username, -600 user_id,'Y' is_valid from dual order by 1 desc;
    
    open l_actual for select username, user_id,'Y' is_valid from all_users union all
    select 'TEST' username, -610 user_id,'Y' is_valid from dual order by 1 asc;
     
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by(ut3.ut_varchar2_list('USERNAME,IS_VALID'));
    --Assert
 l_expected_message := q'[%Actual: refcursor [ count = % ] was expected to equal: refcursor [ count = % ]
%Diff:%
%Rows: [ 1 differences ]%
%PK <USERNAME>TEST</USERNAME><IS_VALID>Y</IS_VALID> - Actual:%<USER_ID>-610</USER_ID>%
%PK <USERNAME>TEST</USERNAME><IS_VALID>Y</IS_VALID> - Expected:%<USER_ID>-600</USER_ID>%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
  
  procedure unord_incl_cols_as_list
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col"  from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col"  from dual a connect by level < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).include(ut3.ut_varchar2_list('RN','//A_Column','SOME_COL')).unordered;
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure joinby_incl_cols_as_list
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col"  from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col"  from dual a connect by level < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).include(ut3.ut_varchar2_list('RN','//A_Column','SOME_COL')).join_by('SOME_COL');
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure joinby_excl_cols_as_list
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col"  from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col"  from dual a connect by level < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).exclude(ut3.ut_varchar2_list('//Some_Col','A_COLUMN')).join_by('SOME_COL');
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure unord_excl_cols_as_list
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col"  from dual a connect by level < 4;
    open l_expected for select rownum as rn, 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col"  from dual a connect by level < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).exclude(ut3.ut_varchar2_list('A_COLUMN|//Some_Col')).unordered;
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;
  
  procedure excl_dif_cols_as_list
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'TEST' as A_COLUMN  from dual a connect by level < 4;
    open l_expected for select rownum as rn, 1 as A_COLUMN  from dual a connect by level < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).exclude(ut3.ut_varchar2_list('A_COLUMN'));
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;
  
  procedure inlc_dif_cols_as_list
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'TEST' as A_COLUMN  from dual a connect by level < 4;
    open l_expected for select rownum as rn, 1 as A_COLUMN  from dual a connect by level < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).include(ut3.ut_varchar2_list('RN'));
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure inlc_exc_dif_cols_as_list
  as
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual   for select rownum as rn, 'TEST' as A_COLUMN  from dual a connect by level < 4;
    open l_expected for select rownum as rn, 1 as A_COLUMN  from dual a connect by level < 4;
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).include(ut3.ut_varchar2_list('RN')).exclude(ut3.ut_varchar2_list('A_COLUMN'));
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;
    
  procedure compare_obj_typ_col_un is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual for select test_dummy_object( rownum, 'Something '||rownum, rownum) as colval
      from dual connect by level <=2 order by rownum asc;

    open l_expected for select test_dummy_object( rownum, 'Something '||rownum, rownum) as colval
      from dual connect by level <=2 order by rownum desc;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).unordered;
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;
  
    procedure compare_obj_typ_col_jb is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual for select test_dummy_object( rownum, 'Something '||rownum, rownum) as colval
      from dual connect by level <=2 order by rownum asc;

    open l_expected for select test_dummy_object( rownum, 'Something '||rownum, rownum) as colval
      from dual connect by level <=2 order by rownum desc;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('COLVAL/ID');
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure comp_obj_typ_col_un_fail is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    --Arrange
    open l_actual for select test_dummy_object( rownum, 'Something '||rownum, rownum) as colval
      from dual connect by level <=2 order by rownum asc;

    open l_expected for select test_dummy_object( rownum, 'Somethings '||rownum, rownum) as colval
      from dual connect by level <=3 order by rownum desc;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).unordered;
 l_expected_message := q'[%Actual: refcursor [ count = 2 ] was expected to equal: refcursor [ count = 3 ]%
Diff:%
Rows: [ 5 differences ]
%Extra:    <ROW><COLVAL><ID>2</ID><name>Something 2</name><Value>2</Value></COLVAL></ROW>%
%Extra:    <ROW><COLVAL><ID>1</ID><name>Something 1</name><Value>1</Value></COLVAL></ROW>%
%Missing:  <ROW><COLVAL><ID>1</ID><name>Somethings 1</name><Value>1</Value></COLVAL></ROW>%
%Missing:  <ROW><COLVAL><ID>2</ID><name>Somethings 2</name><Value>2</Value></COLVAL></ROW>%
%Missing:  <ROW><COLVAL><ID>3</ID><name>Somethings 3</name><Value>3</Value></COLVAL></ROW>%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
  
  procedure comp_obj_typ_col_jb_fail is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual for select test_dummy_object( rownum, 'Something '||rownum, rownum) as colval
      from dual connect by level <=2 order by rownum asc;

    open l_expected for select test_dummy_object( rownum, 'Somethings '||rownum, rownum) as colval
      from dual connect by level <=2 order by rownum desc;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('COLVAL/ID');
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_not_null();
  end;
  
  procedure comp_obj_typ_col_jb_multi is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual for select rownum as rn,test_dummy_object( rownum, 'Something '||rownum, rownum) as colval
      from dual connect by level <=2 order by rownum asc;

    open l_expected for select rownum as rn,test_dummy_object( rownum, 'Something '||rownum, rownum) as colval
      from dual connect by level <=2 order by rownum desc;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by(ut3.ut_varchar2_list('RN,COLVAL/ID'));
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;
  
  procedure comp_obj_typ_col_jb_nokey is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    --Arrange
    open l_actual for select test_dummy_object( rownum, 'Something '||rownum, rownum) as colval
      from dual connect by level <=2 order by rownum asc;

    open l_expected for select test_dummy_object( rownum, 'Something '||rownum, rownum) as colval
      from dual connect by level <=2 order by rownum desc;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('COLVAL/IDS'); 
    
 l_expected_message := q'[%Actual: refcursor [ count = 2 ] was expected to equal: refcursor [ count = 2 ]%
Diff:%
%Unable to join sets:%
%Join key COLVAL/IDS does not exists in expected%
%Join key COLVAL/IDS does not exists in actual%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
 
  procedure compare_nest_tab_col_jb is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_actual_tab ut3.ut_key_value_pairs := ut3.ut_key_value_pairs();
    l_expected_tab ut3.ut_key_value_pairs := ut3.ut_key_value_pairs();
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    select ut3.ut_key_value_pair(rownum,'Something '||rownum)
    bulk collect into l_actual_tab
    from dual connect by level <=2;
 
    select ut3.ut_key_value_pair(rownum,'Something '||rownum)
    bulk collect into l_expected_tab
    from dual connect by level <=2;
      
    --Arrange
    open l_actual for select key,value
      from table(l_actual_tab) order by 1 asc;

    open l_expected for select key,value
      from table(l_expected_tab) order by 1 desc;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('KEY');

    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;    
  
  procedure compare_nest_tab_col_jb_fail is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_actual_tab ut3.ut_key_value_pairs := ut3.ut_key_value_pairs();
    l_expected_tab ut3.ut_key_value_pairs := ut3.ut_key_value_pairs();
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    select ut3.ut_key_value_pair(rownum,'Something '||rownum)
    bulk collect into l_actual_tab
    from dual connect by level <=2;
 
    select ut3.ut_key_value_pair(rownum,'Somethings '||rownum)
    bulk collect into l_expected_tab
    from dual connect by level <=2;
      
    --Arrange
    open l_actual for select key,value
      from table(l_actual_tab) order by 1 asc;

    open l_expected for select key,value
      from table(l_expected_tab) order by 1 desc;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('KEY');
 l_expected_message := q'[%Actual: refcursor [ count = 2 ] was expected to equal: refcursor [ count = 2 ]%
%Diff:%
%Rows: [ 2 differences ]%
%PK <KEY>%</KEY> - Actual:   <VALUE>%</VALUE>%
%PK <KEY>%</KEY> - Expected: <VALUE>%</VALUE>%
%PK <KEY>%</KEY> - Actual:   <VALUE>%</VALUE>%
%PK <KEY>%</KEY> - Expected: <VALUE>%</VALUE>%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;    
    
  procedure compare_nest_tab_cols_jb is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_actual_tab ut3.ut_key_value_pairs := ut3.ut_key_value_pairs();
    l_expected_tab ut3.ut_key_value_pairs := ut3.ut_key_value_pairs();
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    select ut3.ut_key_value_pair(rownum,'Something '||rownum)
    bulk collect into l_actual_tab
    from dual connect by level <=2;
 
    select ut3.ut_key_value_pair(rownum,'Something '||rownum)
    bulk collect into l_expected_tab
    from dual connect by level <=2;
      
    --Arrange
    open l_actual for select key,value
      from table(l_actual_tab) order by 1 asc;

    open l_expected for select key,value
      from table(l_expected_tab) order by 1 desc;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by(ut3.ut_varchar2_list('KEY,VALUE'));

    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;    
  
   procedure compare_nest_tab_cols_jb_fail is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_actual_tab ut3.ut_key_value_pairs := ut3.ut_key_value_pairs();
    l_expected_tab ut3.ut_key_value_pairs := ut3.ut_key_value_pairs();
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    select ut3.ut_key_value_pair(rownum,'Something '||rownum)
    bulk collect into l_actual_tab
    from dual connect by level <=2;
 
    select ut3.ut_key_value_pair(rownum,'Somethings '||rownum)
    bulk collect into l_expected_tab
    from dual connect by level <=2;
      
    --Arrange
    open l_actual for select key,value
      from table(l_actual_tab) order by 1 asc;

    open l_expected for select key,value
      from table(l_expected_tab) order by 1 desc;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by(ut3.ut_varchar2_list('KEY,VALUE'));
 l_expected_message := q'[%Actual: refcursor [ count = 2 ] was expected to equal: refcursor [ count = 2 ]%
%Diff:%
%Rows: [ 4 differences ]%
%PK <KEY>%</KEY><VALUE>%</VALUE> - Extra%
%PK <KEY>%</KEY><VALUE>%</VALUE> - Extra%
%PK <KEY>%</KEY><VALUE>%</VALUE> - Missing%
%PK <KEY>%</KEY><VALUE>%</VALUE> - Missing%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;    
  
  procedure compare_tabtype_as_cols_jb is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_actual_tab ut3.ut_key_value_pairs := ut3.ut_key_value_pairs();
    l_expected_tab ut3.ut_key_value_pairs := ut3.ut_key_value_pairs();
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    select ut3.ut_key_value_pair(rownum,'Something '||rownum)
    bulk collect into l_actual_tab
    from dual connect by level <=2;
 
    select ut3.ut_key_value_pair(rownum,'Somethings '||rownum)
    bulk collect into l_expected_tab
    from dual connect by level <=2;
      
    --Arrange
    open l_actual for select rownum rn, l_actual_tab as nested_table
      from dual connect by level <=2;

    open l_expected for select rownum rn, l_expected_tab as nested_table
      from dual connect by level <=2;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('NESTED_TABLE');
    
    --Assert
 l_expected_message := q'[%Actual: refcursor [ count = 2 ] was expected to equal: refcursor [ count = 2 ]%
%Diff:%
%Rows: [ 2 differences ]%
%PK <NESTED_TABLE>%<UT_KEY_VALUE_PAIR>%<KEY>%</KEY>%<VALUE>%</VALUE>%</UT_KEY_VALUE_PAIR>%<UT_KEY_VALUE_PAIR>%<KEY>%</KEY>%<VALUE>%</VALUE>%</UT_KEY_VALUE_PAIR></NESTED_TABLE>%Extra%<RN>%</RN>%
%PK <NESTED_TABLE>%<UT_KEY_VALUE_PAIR>%<KEY>%</KEY>%<VALUE>%</VALUE>%</UT_KEY_VALUE_PAIR>%<UT_KEY_VALUE_PAIR>%<KEY>%</KEY>%<VALUE>%</VALUE>%</UT_KEY_VALUE_PAIR></NESTED_TABLE>%Extra%<RN>%</RN>%
%PK <NESTED_TABLE>%<UT_KEY_VALUE_PAIR>%<KEY>%</KEY>%<VALUE>%</VALUE>%</UT_KEY_VALUE_PAIR>%<UT_KEY_VALUE_PAIR>%<KEY>%</KEY>%<VALUE>%</VALUE>%</UT_KEY_VALUE_PAIR></NESTED_TABLE>%Missing%<RN>%</RN>%
%PK <NESTED_TABLE>%<UT_KEY_VALUE_PAIR>%<KEY>%</KEY>%<VALUE>%</VALUE>%</UT_KEY_VALUE_PAIR>%<UT_KEY_VALUE_PAIR>%<KEY>%</KEY>%<VALUE>%</VALUE>%</UT_KEY_VALUE_PAIR></NESTED_TABLE>%Missing%<RN>%</RN>%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);

  end;    
  
  procedure compare_tabtype_as_cols is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_actual_tab ut3.ut_key_value_pairs := ut3.ut_key_value_pairs();
    l_expected_tab ut3.ut_key_value_pairs := ut3.ut_key_value_pairs();
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    select ut3.ut_key_value_pair(rownum,'Something '||rownum)
    bulk collect into l_actual_tab
    from dual connect by level <=2 order by rownum asc;
 
    select ut3.ut_key_value_pair(rownum,'Something '||rownum)
    bulk collect into l_expected_tab
    from dual connect by level <=2 order by rownum asc;
      
    --Arrange
    open l_actual for select rownum rn, l_actual_tab as nested_table
      from dual connect by level <=2;

    open l_expected for select rownum rn, l_expected_tab as nested_table
      from dual connect by level <=2;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected);
      --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
    
  end;    

  procedure compare_tabtype_as_cols_coll is
      l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_actual_tab ut3.ut_key_value_pairs := ut3.ut_key_value_pairs();
    l_expected_tab ut3.ut_key_value_pairs := ut3.ut_key_value_pairs();
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    select ut3.ut_key_value_pair(rownum,'Something '||rownum)
    bulk collect into l_actual_tab
    from dual connect by level <=2;
 
    select ut3.ut_key_value_pair(rownum,'Somethings '||rownum)
    bulk collect into l_expected_tab
    from dual connect by level <=2;
      
    --Arrange
    open l_actual for select rownum rn, l_actual_tab as nested_table
      from dual connect by level <=2;

    open l_expected for select rownum rn, l_expected_tab as nested_table
      from dual connect by level <=2;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('NESTED_TABLE/UT_KEY_VALUE_PAIR');
    
    --Assert
 l_expected_message := q'[%Actual: refcursor [ count = 2 ] was expected to equal: refcursor [ count = 2 ]
%Diff:
%Unable to join sets:
%Join key NESTED_TABLE/UT_KEY_VALUE_PAIR does not exists in expected%
%Join key NESTED_TABLE/UT_KEY_VALUE_PAIR does not exists in actual%
%Please make sure that your join clause is not refferring to collection element%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);

  end;   

  procedure compare_rec_colltype_as_cols is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_actual_tab ut3.ut_annotated_object;
    l_expected_tab ut3.ut_annotated_object;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    select ut3.ut_annotated_object('TEST','TEST','TEST',
      ut3.ut_annotations(ut3.ut_annotation(1,'test','test','test'),
                         ut3.ut_annotation(2,'test','test','test'))
    )
    into l_actual_tab from dual;
 
    select ut3.ut_annotated_object('TEST','TEST','TEST',
      ut3.ut_annotations(ut3.ut_annotation(1,'test','test','test'),
                         ut3.ut_annotation(2,'test','test','test'))
    )
    into l_expected_tab from dual;
      
    --Arrange
    open l_actual for select l_actual_tab as nested_table from dual;

    open l_expected for select l_expected_tab as nested_table from dual;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('NESTED_TABLE');
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();

  end; 
  
  procedure compare_rec_colltype_as_attr is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_actual_tab ut3.ut_annotated_object;
    l_expected_tab ut3.ut_annotated_object;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    select ut3.ut_annotated_object('TEST','TEST','TEST',
      ut3.ut_annotations(ut3.ut_annotation(1,'test','test','test'),
                         ut3.ut_annotation(2,'test','test','test'))
    )
    into l_actual_tab from dual;
 
    select ut3.ut_annotated_object('TEST','TEST','TEST',
      ut3.ut_annotations(ut3.ut_annotation(1,'test','test','test'),
                         ut3.ut_annotation(2,'test','test','test'))
    )
    into l_expected_tab from dual;
      
    --Arrange
    open l_actual for select l_actual_tab as nested_table from dual;

    open l_expected for select l_expected_tab as nested_table from dual;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('NESTED_TABLE/OBJECT_OWNER');
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();

  end;   
  
  procedure compare_collection_in_rec is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_actual_tab ut3.ut_annotated_object;
    l_expected_tab ut3.ut_annotated_object;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    select ut3.ut_annotated_object('TEST','TEST','TEST',
      ut3.ut_annotations(ut3.ut_annotation(1,'test','test','test'),
                         ut3.ut_annotation(2,'test','test','test'))
    )
    into l_actual_tab from dual;
 
    select ut3.ut_annotated_object('TEST','TEST','TEST',
      ut3.ut_annotations(ut3.ut_annotation(1,'test','test','test'),
                         ut3.ut_annotation(2,'test','test','test'))
    )
    into l_expected_tab from dual;
      
    --Arrange
    open l_actual for select l_actual_tab as nested_table from dual;

    open l_expected for select l_expected_tab as nested_table from dual;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('NESTED_TABLE/ANNOTATIONS');
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();

  end;   
  
  procedure compare_rec_coll_as_cols_fl is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_actual_tab ut3.ut_annotated_object;
    l_expected_tab ut3.ut_annotated_object;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    select ut3.ut_annotated_object('TEST','TEST','TEST',
      ut3.ut_annotations(ut3.ut_annotation(1,'test','test','test'),
                         ut3.ut_annotation(2,'test','test','test'))
    )
    into l_actual_tab
    from dual;
 
    select ut3.ut_annotated_object('TEST','TEST','TEST',
      ut3.ut_annotations(ut3.ut_annotation(1,'1test','test','test'),
                         ut3.ut_annotation(2,'test','test','test'))
    )
    into l_expected_tab
    from dual;
      
    --Arrange
    open l_actual for select rownum rn, l_actual_tab as nested_table
      from dual;

    open l_expected for select rownum rn, l_expected_tab as nested_table
      from dual;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('NESTED_TABLE/OBJECT_OWNER');
    
    --Assert
     l_expected_message := q'[%Actual: refcursor [ count = 1 ] was expected to equal: refcursor [ count = 1 ]
%Diff:
%Rows: [ 1 differences ]
%PK <OBJECT_OWNER>TEST</OBJECT_OWNER> - Actual:   <NESTED_TABLE><OBJECT_OWNER>TEST</OBJECT_OWNER><OBJECT_NAME>TEST</OBJECT_NAME><OBJECT_TYPE>TEST</OBJECT_TYPE><ANNOTATIONS><UT_ANNOTATION><POSITION>1</POSITION><NAME>test</NAME><TEXT>test</TEXT><SUBOBJECT_NAME>test</SUBOBJECT_NAME></UT_ANNOTATION><UT_ANNOTATION><POSITION>2</POSITION><NAME>test</NAME><TEXT>test</TEXT><SUBOBJECT_NAME>test</SUBOBJECT_NAME></UT_ANNOTATION></ANNOTATIONS></NESTED_TABLE>%
%PK <OBJECT_OWNER>TEST</OBJECT_OWNER> - Expected: <NESTED_TABLE><OBJECT_OWNER>TEST</OBJECT_OWNER><OBJECT_NAME>TEST</OBJECT_NAME><OBJECT_TYPE>TEST</OBJECT_TYPE><ANNOTATIONS><UT_ANNOTATION><POSITION>1</POSITION><NAME>1test</NAME><TEXT>test</TEXT><SUBOBJECT_NAME>test</SUBOBJECT_NAME></UT_ANNOTATION><UT_ANNOTATION><POSITION>2</POSITION><NAME>test</NAME><TEXT>test</TEXT><SUBOBJECT_NAME>test</SUBOBJECT_NAME></UT_ANNOTATION></ANNOTATIONS></NESTED_TABLE>%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
   --ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;  

  procedure compare_rec_coll_as_join is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_actual_tab ut3.ut_annotated_object;
    l_expected_tab ut3.ut_annotated_object;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    select ut3.ut_annotated_object('TEST','TEST','TEST',
      ut3.ut_annotations(ut3.ut_annotation(1,'1test','test','test'),
                         ut3.ut_annotation(2,'test','test','test'))
    )
    into l_actual_tab from dual;
 
    select ut3.ut_annotated_object('TEST','TEST','TEST',
      ut3.ut_annotations(ut3.ut_annotation(1,'test','test','test'),
                         ut3.ut_annotation(2,'test','test','test'))
    )
    into l_expected_tab from dual;
      
    --Arrange
    open l_actual for select l_actual_tab as nested_table from dual;

    open l_expected for select l_expected_tab as nested_table from dual;
    
    --Act
    ut3.ut.expect(l_actual).to_equal(l_expected).join_by('NESTED_TABLE/ANNOTATIONS/TEXT');
    
    --Assert
 l_expected_message := q'[%Actual: refcursor [ count = 1 ] was expected to equal: refcursor [ count = 1 ]%
%Diff:%
%Unable to join sets:%
%Join key NESTED_TABLE/ANNOTATIONS/TEXT does not exists in expected%
%Join key NESTED_TABLE/ANNOTATIONS/TEXT does not exists in actual%
%Please make sure that your join clause is not refferring to collection element%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);

  end;  
  
end;
/
