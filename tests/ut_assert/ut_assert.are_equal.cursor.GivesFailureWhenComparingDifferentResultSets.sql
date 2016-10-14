PROMPT Gives a failure when comparing different result sets
--Arrange

declare
  l_expected sys_refcursor;
  l_actual   sys_refcursor;
  l_result   integer;
begin
--Arrange
  open l_expected for select * from user_objects where rownum <=2;
  open l_actual for select * from user_procedures where rownum <=2;
--Act
  ut_assert.are_equal( l_expected, l_actual );
  l_result :=  ut_assert_processor.get_aggregate_asserts_result();
--Assert
  if l_result = ut_utils.tr_failure then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.tr_failure||''', got: '''||l_result||'''' );
  end if;
end;
/
