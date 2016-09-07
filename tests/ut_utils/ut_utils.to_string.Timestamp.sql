PROMPT Returns a full string representation of a timestamp with maximum precission

--Arrange
declare
  l_value    timestamp(9) := to_timestamp('2016-12-31 23:59:59.123456789', 'yyyy-mm-dd hh24:mi:ss.ff');
  l_expected varchar2(100) := '2016-12-31 23:59:59.123456789';
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
