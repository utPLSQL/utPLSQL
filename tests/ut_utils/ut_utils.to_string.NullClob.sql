PROMPT Returns a 'NULL' as a string representation of null clob

--Arrange
declare
  l_expected varchar2(100) := 'NULL';
  l_result   varchar2(100);
begin
--Act
  l_result :=  ut_utils.to_String(to_clob(NULL));
--Assert
  if l_result = l_expected then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '||l_expected||', got: '||l_result );
  end if;
end;
/
