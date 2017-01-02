--Arrange
declare
  l_expected     &&1 := &&2;
  l_actual       &&1 := &&3;
  l_results      ut_assert_results;
  l_test_message varchar2(30) := 'A test message';
begin
--Act
  ut.expect(l_actual, l_test_message).to_equal(l_expected);
  l_results :=  ut_assert_processor.get_asserts_results();
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and treat(l_results(1) as ut_assert_result).message like ''||l_test_message||'' then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||treat(l_results(1) as ut_assert_result).message||''' to match ''%'||l_test_message||'%''' );
  end if;
end;
/
