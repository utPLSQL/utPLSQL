--Arrange
declare
  l_value    date := to_date('2016-12-31 23:59:59', 'yyyy-mm-dd hh24:mi:ss');
  l_expected varchar2(100) := '2016-12-31T23:59:59';
  l_result   varchar2(100);
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
