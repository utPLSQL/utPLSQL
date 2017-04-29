--Arrange
declare
  l_var &&1;
begin
  --Act
  l_var := &&2;
  ut.expect(anydata.&&3(l_var)).to_be_empty();
   --Assert
  if ut_expectation_processor.get_status = &&4 then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||&&4||''', got: '''||ut_expectation_processor.get_status||'''' );
  end if;
end;
/
