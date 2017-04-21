--Arrange
declare
  l_value1 &&1 := &&2;
  l_value2 &&1 := &&3;
begin
--Act
  ut.expect(l_value1).to_(be_less_or_equal(l_value2));
--Assert
  if ut_expectation_processor.get_status = &&4 then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||&&4||''', got: '''||ut_expectation_processor.get_status||'''' );
  end if;
end;
/
