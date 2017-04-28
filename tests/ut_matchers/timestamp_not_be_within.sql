--Arrange
declare
  l_value timestamp := to_timestamp('1997-01-31 09:00:00.00','YYYY-MM-DD HH24.MI.SS.FF');
  l_value_upper timestamp := to_timestamp('1997-01-31 09:14:25.00','YYYY-MM-DD HH24.MI.SS.FF');
  l_value_lower timestamp := to_timestamp('1997-01-31 08:45:37.00','YYYY-MM-DD HH24.MI.SS.FF');
  l_result integer;
  l_asserts_results ut_assert_results;
begin
  --Act
  ut.expect(l_value_upper).to_(be_within(1,l_value));
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
