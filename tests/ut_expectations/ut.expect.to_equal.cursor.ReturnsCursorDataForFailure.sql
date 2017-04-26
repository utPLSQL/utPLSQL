PROMPT Gives a success when comparing values of different cursors
--Arrange
declare
  l_actual   SYS_REFCURSOR;
  l_expected SYS_REFCURSOR;
  l_result   ut_expectation_result;
  l_expected_string  varchar2(32767);
  l_actual_string    varchar2(32767);
begin
--Act
  open l_actual for select * from user_objects where rownum <=2;
  open l_expected for select * from user_objects where rownum <=3;
  ut.expect(l_actual).to_equal(l_expected);

  l_result := ut_expectation_processor.get_expectations_results()(1);
  l_expected_string := l_result.expected_value_string;
  l_actual_string := l_result.actual_value_string;
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and l_expected_string != 'NULL' and l_actual_string != 'NULL' then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected not null values and got: '''||l_expected_string||''', '''||l_actual_string||'''' );
  end if;
end;
/
