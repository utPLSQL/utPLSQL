--Arrange
declare
  l_value1 &&1 := &&2;
  l_value_lower &&1 := &&3;
  l_value_upper &&1 := &&4;
  l_result integer;
  l_asserts_results ut_expectation_results;
begin
--Act
  ut.expect(l_value1).to_(be_between(l_value_lower,l_value_upper));
  l_asserts_results := ut_expectation_processor.get_asserts_results();
  l_result := l_asserts_results(l_asserts_results.last).status;
--Assert
  if l_result = &&5 then
    :test_result := ut_utils.tr_success;
  else
    :test_result := ut_utils.tr_failure;
    dbms_output.put_line('expected: '''||&&5||''', got: '''||l_result||'''' );
  end if;
end;
/
