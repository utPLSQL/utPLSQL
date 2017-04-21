--Arrange
declare
  l_actual   &&1 := &&3;
  l_expected &&2 := &&4;
  l_result   integer;
begin
--Act
  ut.expect(l_actual).to_equal(l_expected);
  l_result :=  ut_expectation_processor.get_status();
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and l_result = ut_utils.tr_failure then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.tr_failure||''', got: '''||l_result||'''' );
  end if;
end;
/
