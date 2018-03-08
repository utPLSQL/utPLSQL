--Arrange
declare
  l_expected department$ := department$('hr');
  l_actual   department$ := department$('hr');
  l_result   integer;
begin
--Act
  ut.expect( anydata.convertObject(l_actual) ).not_to_equal( anydata.convertObject(l_expected) );
  l_result :=  ut_expectation_processor.get_status();
--Assert
  if l_result = ut_utils.tr_failure then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.tr_success||''', got: '''||l_result||'''' );
  end if;
end;
/
