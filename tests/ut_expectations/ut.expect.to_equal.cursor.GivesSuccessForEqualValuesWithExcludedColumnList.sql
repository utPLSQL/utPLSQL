PROMPT Gives a success when cursors are identical ignoring excluded column list
--Arrange
declare
  l_actual   SYS_REFCURSOR;
  l_expected SYS_REFCURSOR;
  l_result   integer;
begin
--Act
  open l_actual for select a.*, systimestamp as cursor_timestamp, 'a' as some_column from user_objects a where rownum <=4;
  open l_expected for select a.*, systimestamp as cursor_timestamp, 'b' as some_column  from user_objects a where rownum <=4;
  ut.expect(l_actual).to_equal(l_expected, a_exclude=> ut_varchar2_list('CURSOR_TIMESTAMP','SOME_COLUMN'));
  l_result :=  ut_expectation_processor.get_status();
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and l_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.tr_success||''', got: '''||l_result||'''' );
  end if;
end;
/
