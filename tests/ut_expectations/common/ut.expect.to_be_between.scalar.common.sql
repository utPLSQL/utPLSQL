--Arrange
declare
  l_actual   &&1 := &&2;
  l_expected_1 &&1 := &&3;
  l_expected_2 &&1 := &&4;
  l_result   integer;
begin
--Act
  ut.expect(l_actual).to_be_between(l_expected_1,l_expected_2);
  l_result :=  ut_assert_processor.get_aggregate_asserts_result();
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and l_result = &&5 then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||&&5||''', got: '''||l_result||'''' );
  end if;
end;
/
