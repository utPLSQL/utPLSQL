PROMPT Gives a success when expression evaluates to a boolean true
--Arrange
declare
  l_result   integer;
begin
--Act
  ut.expect( 1 = 1 ).to_be_true();
  ut.expect( 1 = 1 ).not_to_be_false();
  l_result :=  ut_expectation_processor.get_status();
--Assert
  if nvl(:test_result, ut_utils.gc_success) = ut_utils.gc_success and l_result = ut_utils.gc_success then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.gc_success||''', got: '''||l_result||'''' );
  end if;
end;
/




