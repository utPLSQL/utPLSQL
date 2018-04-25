--Arrange
declare
  l_actual   SYS_REFCURSOR;
  l_expected SYS_REFCURSOR;
  l_result   integer;
begin
--Act
  open l_actual for select sysdate as some_date from dual;
  open l_expected for select to_char(sysdate) some_date from dual;
  ut.expect(l_actual).to_equal(l_expected);
  l_result :=  ut_expectation_processor.get_status();
--Assert
  if nvl(:test_result, ut_utils.gc_success) = ut_utils.gc_success and l_result = ut_utils.gc_success then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.gc_success||''', got: '''||l_result||'''' );
  end if;
end;
/
