--Arrange
declare
  l_mask     varchar2(10) := 'a%/_b';
  l_string   varchar2(50) := 'asdfsdfsdf_b';
  l_result   integer;
begin
--Act
  ut_assert.is_like('', l_string, l_mask, '/');
  l_result :=  ut_assert_processor.get_aggregate_asserts_result();
--Assert
  if l_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: string like'''||l_mask||''' with escape ''/'', got: '''||l_result||'''' );
  end if;
end;
/
