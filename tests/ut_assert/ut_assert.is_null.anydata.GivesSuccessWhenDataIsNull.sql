PROMPT Gives a success when oracle object is null
--Arrange
declare
  l_actual   department$;
  l_result   integer;
begin
--Act
  ut_assert.is_null( anydata.convertObject(l_actual) );
  l_result :=  ut_assert_processor.get_aggregate_asserts_result();
--Assert
  if l_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.tr_success||''', got: '''||l_result||'''' );
  end if;
end;
/

