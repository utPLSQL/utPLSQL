PROMPT Returns differing rows when compared cursor data is different
--Arrange
declare
  l_actual   sys_refcursor;
  l_expected sys_refcursor;
  l_result   ut_expectation_result;
begin
--Act
  open l_actual for select * from user_objects where rownum <=2;
  open l_expected for select * from user_objects where rownum <=3;
  ut.expect(l_actual).to_equal(l_expected);

  l_result := treat( ut_expectation_processor.get_failed_expectations()(1) as ut_expectation_result );
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success
     and l_result.message like q'[Actual:%
    (rows: 2, mismatched: 1)
 (refcursor)%
was expected to equal:%
    (rows: 3, mismatched: 1)
    row_no: 3     <ROW>%</ROW>
 (refcursor)%]' then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected not null data and got: '''||l_result.message||'''' );
  end if;
end;
/
