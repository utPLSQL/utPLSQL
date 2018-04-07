--Arrange
declare
  l_value    clob := lpad('A test char',32767,'1')||lpad('1',32767,'1');
  l_result   varchar2(32767);
  l_delimiter varchar2(1);
begin
--Act
  l_result :=  ut_utils.to_String(l_value);
--Assert
  if length(l_result) != ut_utils.gc_max_output_string_length then
    dbms_output.put_line('expected: length(l_result)='||ut_utils.gc_max_output_string_length||', got: '||length(l_result) );
  elsif l_result not like '%'||ut_utils.gc_more_data_string then
    dbms_output.put_line('expected: l_result to match %'||ut_utils.gc_more_data_string||', got: '||substr(l_result,-10) );
  else
    :test_result := ut_utils.gc_success;
  end if;
end;
/
