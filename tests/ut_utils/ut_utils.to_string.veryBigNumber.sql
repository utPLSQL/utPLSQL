--Arrange
declare
  l_value    number := 1234567890123456789012345678901234567890;
  l_expected varchar2(100) := '1234567890123456789012345678901234567890';
  l_result   varchar2(100);
begin
--Act
  l_result :=  ut_utils.to_String(l_value);
--Assert
  if l_result = l_expected then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '||l_expected||', got: '||l_result );
  end if;
end;
/
