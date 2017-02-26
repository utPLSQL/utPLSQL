PROMPT Gives a success when the Cursor is null
--Arrange
declare
  l_cursor sys_refcursor;
  l_result   integer;
begin
--Act
  ut.expect( l_cursor ).to_be_null();
  l_result :=  ut_assert_processor.get_aggregate_asserts_result();
--Assert
  if l_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.tr_success||''', got: '''||l_result||'''' );
  end if;
end;
/
