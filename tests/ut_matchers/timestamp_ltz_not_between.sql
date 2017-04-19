--Arrange
declare
  l_value_tlz timestamp with local time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +01:00','YYYY-MM-DD HH24.MI.SS.FF TZR');
  l_value_lower_tlz timestamp with local time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +02:00','YYYY-MM-DD HH24.MI.SS.FF TZR');
  l_value_upper_tlz timestamp with local time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +03:00','YYYY-MM-DD HH24.MI.SS.FF TZR');
begin
  --Act
  ut.expect(l_value_tlz).to_(be_between(l_value_lower_tlz,l_value_upper_tlz));
  --Assert
  if ut_expectation_processor.get_status = ut_utils.tr_failure then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.tr_failure||''', got: '''||ut_expectation_processor.get_status||'''' );
  end if;
end;
/

