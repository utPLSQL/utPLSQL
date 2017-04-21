--Arrange
declare
  l_expected     &&1 := &&2;
  l_actual       &&1 := &&3;
  l_result      ut_expectation_result;
  l_test_message varchar2(30) := 'A test message';
begin
--Act
  ut.expect(l_actual, l_test_message).to_equal(l_expected);
  l_result :=  ut_expectation_processor.get_expectations_results()(1);
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and l_result.message like ''||l_test_message||'' then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||l_result.message||''' to match ''%'||l_test_message||'%''' );
  end if;
end;
/
