--Arrange
declare
  l_actual   &&1 := &&3;
  l_expected &&2 := &&4;
  l_result   integer;
  l_message  varchar2(32767);
begin
--Act
  ut.expect(l_actual).&&5.to_equal(l_expected);
  l_result :=  ut_expectation_processor.get_status();
  l_message := ut_expectation_processor.get_failed_expectations()(1).get_result_clob;
--Assert
  if nvl(:test_result, ut_utils.gc_success) = ut_utils.gc_success and l_result = ut_utils.gc_failure
    and l_message like 'Actual (%) cannot be compared to Expected (%) using matcher%' then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.gc_failure||''', got: '''||l_result||'''' );
  end if;
end;
/
