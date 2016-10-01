--Arrange
declare
  l_mask     varchar2(10) := 'a%b';
  l_string   varchar2(50) := 'asdfsdfsdfb';
  l_result   integer;
begin
--Act
  ut_assert.str_like(l_string, l_mask);
  l_result :=  ut_assert.get_aggregate_asserts_result();
--Assert
  if l_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: string like'''||l_mask||''', got: '''||l_result||'''' );
  end if;
end;
/
