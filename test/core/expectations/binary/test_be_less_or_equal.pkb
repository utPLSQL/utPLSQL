create or replace package body test_be_less_or_equal is

  procedure cleanup_expectations is
  begin
    expectations.cleanup_expectations( );
  end;

  function to_less_or_equal_block(
    a_data_type varchar2,
    a_actual    varchar2,
    a_expected  varchar2
  ) return varchar2 is
  begin
    return expectations.binary_expectation_block(
        'to_be_less_or_equal', a_data_type, a_actual, a_data_type, a_expected
    );
  end;

  function not_to_less_or_equal_block(
    a_data_type varchar2,
    a_actual    varchar2,
    a_expected  varchar2
  ) return varchar2 is
    begin
      return expectations.binary_expectation_block(
          'not_to_be_less_or_equal', a_data_type, a_actual, a_data_type, a_expected
      );
    end;

  procedure actual_date_greater is
    begin
      --Act
      execute immediate to_less_or_equal_block('date', 'sysdate', 'sysdate-1');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty();
    end;

  procedure actual_number_greater is
    begin
      --Act
      execute immediate to_less_or_equal_block('number', '2.0', '1.99');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty();
    end;

  procedure actual_interval_ym_greater is
    begin
      --Act
      execute immediate to_less_or_equal_block('interval year to month', '''2-1''', '''2-0''');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty();
    end;

  procedure actual_interval_ds_greater is
    begin
      --Act
      execute immediate to_less_or_equal_block('interval day to second', '''2 01:00:00''', '''2 00:59:59''');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty();
    end;

  procedure actual_timestamp_greater is
    begin
      --Act
      execute immediate to_less_or_equal_block('timestamp', 'to_timestamp(''1997 13'',''YYYY FF'')', 'to_timestamp(''1997 12'',''YYYY FF'')');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty();
    end;

  procedure actual_timestamp_tz_greater is
    begin
      --Act
      execute immediate to_less_or_equal_block('timestamp with time zone', 'to_timestamp_tz(''1997 12 +01:00'',''YYYY FF TZR'')', 'to_timestamp_tz(''1997 12 +02:00'',''YYYY FF TZR'')');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty();
    end;

  procedure actual_timestamp_ltz_greater is
    begin
      --Act
      execute immediate to_less_or_equal_block('timestamp with local time zone', 'to_timestamp_tz(''1997 12 +01:00'',''YYYY FF TZR'')', 'to_timestamp_tz(''1997 12 +02:00'',''YYYY FF TZR'')');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty();
    end;

  procedure actual_date_equal is
    begin
      --Act
      execute immediate to_less_or_equal_block('date', 'sysdate', 'sysdate');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure actual_number_equal is
    begin
      --Act
      execute immediate to_less_or_equal_block('number', '2.0', '2.00');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure actual_interval_ym_equal is
    begin
      --Act
      execute immediate to_less_or_equal_block('interval year to month', '''2-1''', '''2-1''');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure actual_interval_ds_equal is
    begin
      --Act
      execute immediate to_less_or_equal_block('interval day to second', '''2 01:00:00''', '''2 01:00:00''');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure actual_timestamp_equal is
    begin
      --Act
      execute immediate to_less_or_equal_block('timestamp', 'to_timestamp(''1997 13'',''YYYY FF'')', 'to_timestamp(''1997 13'',''YYYY FF'')');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure actual_timestamp_tz_equal is
    begin
      --Act
      execute immediate to_less_or_equal_block('timestamp with time zone', 'to_timestamp_tz(''1997 12 +01:00'',''YYYY FF TZR'')', 'to_timestamp_tz(''1997 12 +01:00'',''YYYY FF TZR'')');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure actual_timestamp_ltz_equal is
    begin
      --Act
      execute immediate to_less_or_equal_block('timestamp with local time zone', 'to_timestamp_tz(''1997 12 +01:00'',''YYYY FF TZR'')', 'to_timestamp_tz(''1997 12 +01:00'',''YYYY FF TZR'')');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure actual_date_less is
    begin
      --Act
      execute immediate to_less_or_equal_block('date', 'sysdate-1', 'sysdate');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure actual_number_less is
    begin
      --Act
      execute immediate to_less_or_equal_block('number', '1.0', '1.01');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure actual_interval_ym_less is
    begin
      --Act
      execute immediate to_less_or_equal_block('interval year to month', '''2-1''', '''2-2''');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure actual_interval_ds_less is
    begin
      --Act
      execute immediate to_less_or_equal_block('interval day to second', '''2 00:59:58''', '''2 00:59:59''');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure actual_timestamp_less is
    begin
      --Act
      execute immediate to_less_or_equal_block('timestamp', 'to_timestamp(''1997 12'',''YYYY FF'')', 'to_timestamp(''1997 13'',''YYYY FF'')');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure actual_timestamp_tz_less is
    begin
      --Act
      execute immediate to_less_or_equal_block('timestamp with time zone', 'to_timestamp_tz(''1997 12 +03:00'',''YYYY FF TZR'')', 'to_timestamp_tz(''1997 12 +02:00'',''YYYY FF TZR'')');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure actual_timestamp_ltz_less is
    begin
      --Act
      execute immediate to_less_or_equal_block('timestamp with local time zone', 'to_timestamp_tz(''1997 12 +03:00'',''YYYY FF TZR'')', 'to_timestamp_tz(''1997 12 +02:00'',''YYYY FF TZR'')');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure not_actual_date_greater is
    begin
      --Act
      execute immediate not_to_less_or_equal_block('date', 'sysdate', 'sysdate-1');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure not_actual_number_greater is
    begin
      --Act
      execute immediate not_to_less_or_equal_block('number', '2.0', '1.99');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure not_actual_interval_ym_greater is
    begin
      --Act
      execute immediate not_to_less_or_equal_block('interval year to month', '''2-1''', '''2-0''');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure not_actual_interval_ds_greater is
    begin
      --Act
      execute immediate not_to_less_or_equal_block('interval day to second', '''2 01:00:00''', '''2 00:59:59''');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure not_actual_timestamp_greater is
    begin
      --Act
      execute immediate not_to_less_or_equal_block('timestamp', 'to_timestamp(''1997 13'',''YYYY FF'')', 'to_timestamp(''1997 12'',''YYYY FF'')');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure not_actual_timestamp_tz_gretr is
    begin
      --Act
      execute immediate not_to_less_or_equal_block('timestamp with time zone', 'to_timestamp_tz(''1997 12 +01:00'',''YYYY FF TZR'')', 'to_timestamp_tz(''1997 12 +02:00'',''YYYY FF TZR'')');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

  procedure not_actual_timestamp_ltz_gretr is
    begin
      --Act
      execute immediate not_to_less_or_equal_block('timestamp with local time zone', 'to_timestamp_tz(''1997 12 +01:00'',''YYYY FF TZR'')', 'to_timestamp_tz(''1997 12 +02:00'',''YYYY FF TZR'')');
      --Assert
      ut.expect( expectations.failed_expectations_data( ) ).to_be_empty();
    end;

end;
/
