--Arrange
declare
  l_value1 &&1 := &&2;
  l_value_lower &&1 := &&3;
  l_value_upper &&1 := &&4;
begin
--Act
  ut.expect(l_value1).&&6.to_be_between(l_value_lower,l_value_upper);
--Assert
  if ut_expectation_processor.get_status = &&5 then
    :test_result := ut_utils.tr_success;
  else
    :test_result := ut_utils.tr_failure;
    dbms_output.put_line('expected: '''||&&5||''', got: '''||ut_expectation_processor.get_status||'''' );
  end if;
end;
/
