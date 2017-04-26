PROMPT Gives a success when comparing values of different cursors
--Arrange
declare
  l_actual   SYS_REFCURSOR;
  l_expected SYS_REFCURSOR;
  l_result   integer;
begin
--Act
  open l_actual for select * from user_objects where rownum <=4;
  open l_expected for select * from user_objects where rownum <=5;
  ut.expect(l_actual).to_equal(l_expected);
  l_result :=  ut_expectation_processor.get_status();
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and l_result = ut_utils.tr_failure then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.tr_success||''', got: '''||l_result||'''' );
  end if;
end;
/




