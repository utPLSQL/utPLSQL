--Arrange
declare
  l_value    clob := 'A test char';
  l_expected varchar2(32767) := ''''||l_value||'''';
  l_result   varchar2(32767);
  l_delimiter varchar2(1);
begin
--Act
  l_result :=  ut_utils.to_String(l_value);
--Assert
  if l_result = l_expected then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line('expected: '||l_expected||', got: '||l_result );
  end if;
end;
/
