PROMPT Returns a full string representation of a timestamp with maximum precission

--Arrange
declare
  l_value    timestamp(9) with local time zone:= to_timestamp('2016-12-31 23:59:59.123456789', 'yyyy-mm-dd hh24:mi:ss.ff');
  l_expected varchar2(100);
  l_result   varchar2(100);
  l_delimiter varchar2(1);
begin
  select substr(value, 1, 1) into l_delimiter from nls_session_parameters t where t.parameter = 'NLS_NUMERIC_CHARACTERS';
  l_expected := '2016-12-31T23:59:59'||l_delimiter||'123456789';
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
