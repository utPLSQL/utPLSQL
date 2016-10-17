declare
  l_result   integer;
begin
--Act
  ut_assert.this( &1 );
  l_result :=  ut_assert_processor.get_aggregate_asserts_result();
--Assert
  if l_result = &&2 then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||&&2||''', got: '''||l_result||'''' );
  end if;
end;
/
