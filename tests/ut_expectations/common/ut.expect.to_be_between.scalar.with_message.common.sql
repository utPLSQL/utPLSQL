--Arrange
declare
  l_actual   &&1 := &&2;
  l_expected_1 &&1 := &&3;
  l_expected_2 &&1 := &&4;
  l_results      ut_expectation_results;
  l_test_description varchar2(30) := 'A test message';
begin
--Act
  ut.expect(l_actual, l_test_description).to_be_between(l_expected_1, l_expected_2);
  l_results :=  ut_expectation_processor.get_expectations_results();

--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and treat(l_results(1) as ut_expectation_result).description like ''||l_test_description||'' then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||treat(l_results(1) as ut_expectation_result).description||''' to match '''||l_test_description||'''' );
  end if;
end;
/
