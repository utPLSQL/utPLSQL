--Arrange
declare
  l_actual   SYS_REFCURSOR;
  l_expected SYS_REFCURSOR;
  l_result   integer;
  l_date     date := sysdate;
  l_second   number := 1/24/60/60;
begin
--Act
  ut.set_nls;
  open l_actual for select l_date as some_date from dual;
  open l_expected for select l_date-l_second some_date from dual;
  ut.reset_nls;

  ut.expect(l_actual).not_to( equal(l_expected));

  l_result :=  ut_expectation_processor.get_status();
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and l_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.tr_success||''', got: '''||l_result||'''' );
  end if;
end;
/
