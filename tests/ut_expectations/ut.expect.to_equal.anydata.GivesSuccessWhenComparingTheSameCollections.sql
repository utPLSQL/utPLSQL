PROMPT Gives a success when comparing equal oracle collections
--Arrange
declare
  l_expected ut_varchar2_list := ut_varchar2_list('IT');
  l_actual   ut_varchar2_list := ut_varchar2_list('IT');
  l_result   integer;
begin
--Act
  ut.expect( anydata.convertCollection(l_actual) ).to_equal( anydata.convertCollection(l_expected) );
  l_result :=  ut_expectation_processor.get_status();
--Assert
  if l_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.tr_success||''', got: '''||l_result||'''' );
  end if;
end;
/
