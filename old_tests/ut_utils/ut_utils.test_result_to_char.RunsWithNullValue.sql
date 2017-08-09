--Arrange
declare
  l_expected varchar2(20) := 'Unknown(NULL)';
  l_result varchar2(20);
begin
--Act
  l_result :=  ut_utils.test_result_to_char(NULL);
--Assert
  if l_result = l_expected then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '||l_expected||', got: '||l_result );
  end if;
end;
/
