PROMPT Gives a success when comparing null oracle objects of the same type
--Arrange
declare
  l_expected anydata;
  l_actual   anydata;
  l_result   integer;
begin
--Act
  ut.expect( l_actual ).to_equal( l_expected );
  l_result :=  ut_assert_processor.get_aggregate_asserts_result();
--Assert
  if l_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.tr_success||''', got: '''||l_result||'''' );
  end if;
end;
/
