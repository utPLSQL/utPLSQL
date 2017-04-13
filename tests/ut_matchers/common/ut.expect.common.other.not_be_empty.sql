--Arrange
declare
  l_var &&1;
  l_result integer;
  l_asserts_results ut_expectation_results;
begin
  --Act
  l_var := &&2;
  ut.expect(anydata.&&3(l_var)).not_to(be_empty());
  l_asserts_results := ut_expectation_processor.get_asserts_results();
  l_result := l_asserts_results(l_asserts_results.last).status;
   --Assert
  if l_result = &&4 then
    :test_result := ut_utils.tr_success;
  else
    :test_result := ut_utils.tr_failure;
    dbms_output.put_line('expected: '''||&&4||''', got: '''||l_result||'''' );
  end if;
end;
/
