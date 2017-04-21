--Arrange
declare
  l_actual   &&1 := &&3;
  l_expected_1 &&2 := &&4;
  l_expected_2 &&2 := &&5;
  l_result   integer;
begin
--Act
  ut.expect(l_actual).to_be_between(l_expected_1,l_expected_2);
  l_result :=  ut_expectation_processor.get_status();
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and l_result = &&6 then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||&&6||''', got: '''||l_result||'''' );
  end if;
end;
/
