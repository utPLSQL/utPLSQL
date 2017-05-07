--Arrange
declare
  l_cursor sys_refcursor;
begin
  --Act
  open l_cursor for &&1;
  ut.expect(l_cursor).not_to_be_empty();
   --Assert
  if ut_expectation_processor.get_status = &&2 then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||&&2||''', got: '''||ut_expectation_processor.get_status||'''' );
  end if;
end;
/
