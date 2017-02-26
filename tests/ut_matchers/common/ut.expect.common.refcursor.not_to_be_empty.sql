--Arrange
declare
  l_cursor sys_refcursor;
  l_result integer;
  l_asserts_results ut_assert_results;
begin
  --Act
  open l_cursor for &&1;
  ut.expect(l_cursor).not_to(be_empty());
  l_asserts_results := ut_assert_processor.get_asserts_results();
  l_result := l_asserts_results(l_asserts_results.last).result;
   --Assert
  if l_result = &&2 then
    :test_result := ut_utils.tr_success;    
  else
    :test_result := ut_utils.tr_failure;
    dbms_output.put_line('expected: '''||&&2||''', got: '''||l_result||'''' );
  end if;
end;
/
