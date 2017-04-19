--Arrange
declare
  l_actual   &&1 := &&2;
  l_expected &&1 := &&3;
  l_result      ut_expectation_result;
begin
--Act
  ut.expect(l_actual).to_equal(l_expected);
  l_result :=  ut_expectation_processor.get_expectations_results()(1);
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and l_result.&4 = 'NULL' then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: &4 to be NULL, but got '''||l_result.&4||'''' );
  end if;
end;
/
