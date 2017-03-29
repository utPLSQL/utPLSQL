--Arrange
declare
  l_actual &&1 := &&2;
  l_expected &&1 := &&3;
  l_pct NUMBER := &&4;
  l_result integer;
  l_asserts_results ut_assert_results;
begin
--Act
  ut.expect(l_actual).to_(be_within(l_pct,l_expected));
  l_asserts_results := ut_assert_processor.get_asserts_results();
  l_result := l_asserts_results(l_asserts_results.last).result;
--Assert
  if l_result = &&5 then
    :test_result := ut_utils.tr_success;    
  else
    :test_result := ut_utils.tr_failure;
    dbms_output.put_line('expected: '''||&&5||''', got: '''||l_result||'''' );
  end if;
end;
/
