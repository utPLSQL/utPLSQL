--Arrange
declare
  l_value_tz timestamp with time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +01:00','YYYY-MM-DD HH24.MI.SS.FF TZR');
  l_value_lower_tz timestamp with time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +02:00','YYYY-MM-DD HH24.MI.SS.FF TZR');
  l_value_upper_tz timestamp with time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +03:00','YYYY-MM-DD HH24.MI.SS.FF TZR');

  l_result integer;
  l_asserts_results ut_assert_results;
begin
  --Act
  ut.expect(l_value_tz).to_(be_between(l_value_lower_tz,l_value_upper_tz));
  l_asserts_results := ut_assert_processor.get_asserts_results();
  l_result := l_asserts_results(l_asserts_results.last).result;
  --Assert
  if l_result = ut_utils.tr_failure then
    :test_result := ut_utils.tr_success;    
  else
    :test_result := ut_utils.tr_failure;
    dbms_output.put_line('expected: '''||ut_utils.tr_failure||''', got: '''||l_result||'''' );
  end if;
end;
/

