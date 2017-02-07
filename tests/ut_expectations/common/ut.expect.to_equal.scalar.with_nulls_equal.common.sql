--Arrange
declare
  l_expected        &&1 := &&2;
  l_actual          &&1 := &&3;
  l_result          integer;
  l_expected_result integer := &&4;
  l_nulls_are_equal boolean := &&5;
begin
--Act
  ut.expect(l_actual).to_equal(l_expected, l_nulls_are_equal);
  l_result := ut_assert_processor.get_aggregate_asserts_result();
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and l_result = l_expected_result then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||&&4||''', got: '''||l_result||'''' );
  end if;
end;
/
