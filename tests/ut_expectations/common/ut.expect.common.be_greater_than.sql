--Arrange
declare
  l_value1 &&1 := &&2;
  l_value2 &&1 := &&3;
  l_result integer;
  l_asserts_results ut_assert_results;
begin
--Act
  ut.expect(l_value1).to_(be_greater_than(l_value2));
  l_asserts_results := ut_assert_processor.get_asserts_results();
  l_result := l_asserts_results(l_asserts_results.last).result;
--Assert
  if l_result = &&4 then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||&&4||''', got: '''||l_result||'''' );
  end if;
end;
/
