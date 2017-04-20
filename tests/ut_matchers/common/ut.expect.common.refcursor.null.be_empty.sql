--Arrange
declare
  l_cursor sys_refcursor;
  l_result integer;
  l_asserts_results ut_expectation_results;
begin
  --Act
  ut.expect(l_cursor).&1(be_empty());
  l_asserts_results := ut_expectation_processor.get_asserts_results();
  l_result := l_asserts_results(l_asserts_results.last).status;
   --Assert
  if l_result = &&2 then
    :test_result := ut_utils.tr_success;
  else
    :test_result := ut_utils.tr_failure;
    dbms_output.put_line('expected: '''||&&2||''', got: '''||l_result||'''' );
  end if;
end;
/
