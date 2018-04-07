--Arrange
declare
  l_delimiter  varchar2(1) := &2;
  l_expected   clob := &3;
  l_result     clob;
begin
--Act
  l_result := ut_utils.table_to_clob(&1, l_delimiter);
--Assert
  if l_expected is null and l_result is null or l_expected = l_result then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line('Expected: "'||l_expected||'"');
    dbms_output.put_line('Actual: "'||l_result||'"');
  end if;
end;
/
