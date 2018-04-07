--Arrange
declare
  l_value    number := 0.123456789012345678901234567890123456789;
  l_expected varchar2(100) := '.123456789012345678901234567890123456789';
  l_result   varchar2(100);
  l_delimiter varchar2(1);
begin
--Act
  select substr(value, 1, 1) into l_delimiter from nls_session_parameters t where t.parameter = 'NLS_NUMERIC_CHARACTERS';
  l_expected := l_delimiter||'123456789012345678901234567890123456789';

  l_result :=  ut_utils.to_String(l_value);

--Assert
  if l_result = l_expected then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line('expected: '||l_expected||', got: '||l_result );
  end if;
end;
/
