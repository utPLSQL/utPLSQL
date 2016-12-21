--Arrange
declare
  l_value timestamp := to_timestamp('1997-01-31 09:26:50.13','YYYY-MM-DD HH24.MI.SSXFF');
  l_value_lower timestamp := to_timestamp('1997-01-31 09:26:50.11','YYYY-MM-DD HH24.MI.SSXFF');
  l_value_upper timestamp := to_timestamp('1997-01-31 09:26:50.14','YYYY-MM-DD HH24.MI.SSXFF');

  l_result integer;
  l_asserts_results ut_objects_list;
begin
  --Act
  ut.expect(l_value).to_(be_between(l_value_lower,l_value_upper));
  l_asserts_results := ut_assert_processor.get_asserts_results();
  l_result := l_asserts_results(l_asserts_results.last).result;
  --Assert
  if l_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;    
  else
    :test_result := ut_utils.tr_failure;
    dbms_output.put_line('expected: '''||ut_utils.tr_success||''', got: '''||l_result||'''' );
  end if;
end;
/

