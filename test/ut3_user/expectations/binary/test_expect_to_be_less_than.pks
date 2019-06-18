create or replace package test_expect_to_be_less_than is

  --%suite((not)to_be_less_than)
  --%suitepath(utplsql.test_user.expectations.binary)

  --%aftereach
  procedure cleanup_expectations;

  --%test(Gives failure when actual date is greater than expected)
  procedure actual_date_greater;

  --%test(Gives failure when actual number is greater than expected)
  procedure actual_number_greater;

  --%test(Gives failure when actual interval year to month is greater than expected)
  procedure actual_interval_ym_greater;

  --%test(Gives failure when actual interval day to second is greater than expected)
  procedure actual_interval_ds_greater;

  --%test(Gives failure when actual timestamp is greater than expected)
  procedure actual_timestamp_greater;

  --%test(Gives failure when actual timestamp with time zone is greater than expected)
  procedure actual_timestamp_tz_greater;

  --%test(Gives failure when actual timestamp with local time zone is greater than expected)
  procedure actual_timestamp_ltz_greater;

  --%test(Gives failure when actual date is equal expected)
  procedure actual_date_equal;

  --%test(Gives failure when actual number is equal expected)
  procedure actual_number_equal;

  --%test(Gives failure when actual interval year to month is equal expected)
  procedure actual_interval_ym_equal;

  --%test(Gives failure when actual interval day to second is equal expected)
  procedure actual_interval_ds_equal;

  --%test(Gives failure when actual timestamp is equal expected)
  procedure actual_timestamp_equal;

  --%test(Gives failure when actual timestamp with time zone is equal expected)
  procedure actual_timestamp_tz_equal;

  --%test(Gives failure when actual timestamp with local time zone is equal expected)
  procedure actual_timestamp_ltz_equal;

  --%test(Gives success when actual date is less than expected)
  procedure actual_date_less;

  --%test(Gives success when actual number is less than expected)
  procedure actual_number_less;

  --%test(Gives success when actual interval year to month is less than expected)
  procedure actual_interval_ym_less;

  --%test(Gives success when actual interval day to second is less than expected)
  procedure actual_interval_ds_less;

  --%test(Gives success when actual timestamp is less than expected)
  procedure actual_timestamp_less;

  --%test(Gives success when actual timestamp with time zone is less than expected)
  procedure actual_timestamp_tz_less;

  --%test(Gives success when actual timestamp with local time zone is less than expected)
  procedure actual_timestamp_ltz_less;

  --%test(Negated - Gives success when actual date is greater than expected)
  procedure not_actual_date_greater;

  --%test(Negated - Gives success when actual number is greater than expected)
  procedure not_actual_number_greater;

  --%test(Negated - Gives success when actual interval year to month is greater than expected)
  procedure not_actual_interval_ym_greater;

  --%test(Negated - Gives success when actual interval day to second is greater than expected)
  procedure not_actual_interval_ds_greater;

  --%test(Negated - Gives success when actual timestamp is greater than expected)
  procedure not_actual_timestamp_greater;

  --%test(Negated - Gives success when actual timestamp with time zone is greater than expected)
  procedure not_actual_timestamp_tz_gretr;

  --%test(Negated - Gives success when actual timestamp with local time zone is greater than expected)
  procedure not_actual_timestamp_ltz_gretr;

  --%test(Gives failure when running against CLOB)
  procedure actual_clob;

end;
/
