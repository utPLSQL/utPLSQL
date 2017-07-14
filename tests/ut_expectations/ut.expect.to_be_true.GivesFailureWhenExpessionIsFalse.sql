PROMPT Gives a failre when expression evaluates to a boolean false
--Arrange
declare
  l_result   integer;
begin
--Act
  ut.expect( 1 = 0 ).to_be_true();
  ut.expect( 1 = 0 ).not_to_be_false();
  l_result :=  ut_expectation_processor.get_status();
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and l_result = ut_utils.tr_failure then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.tr_failure||''', got: '''||l_result||'''' );
  end if;
end;
/




