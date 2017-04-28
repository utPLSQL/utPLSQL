--Arrange
declare
  l_value timestamp := to_timestamp('1997-01-31 09:26:50.13','YYYY-MM-DD HH24.MI.SS.FF');
  l_value_lower timestamp := to_timestamp('1997-01-31 09:26:50.11','YYYY-MM-DD HH24.MI.SS.FF');
  l_value_upper timestamp := to_timestamp('1997-01-31 09:26:50.12','YYYY-MM-DD HH24.MI.SS.FF');
begin
  --Act
  ut.expect(l_value).to_be_between(l_value_lower,l_value_upper);
  --Assert
  if ut_expectation_processor.get_status = ut_utils.tr_failure then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.tr_failure||''', got: '''||ut_expectation_processor.get_status||'''' );
  end if;
end;
/

