PROMPT Gives a success when the Anydata argument is null
--Arrange
declare
  l_result   integer;
begin
--Act
  ut.expect( cast(null as anydata) ).to_be_null();
  l_result :=  ut_expectation_processor.get_aggregate_asserts_result();
--Assert
  if l_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.tr_success||''', got: '''||l_result||'''' );
  end if;
end;
/
