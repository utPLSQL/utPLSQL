PROMPT Returns a blob converted to varchar and eclosed in quotes

--Arrange
declare
  l_text     varchar2(32767) := 'A test char';
  l_value    blob := utl_raw.cast_to_raw(l_text);
  l_expected varchar2(32767) := ''''||rawtohex(l_value)||'''';
  l_result   varchar2(32767);
  l_delimiter varchar2(1);
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
