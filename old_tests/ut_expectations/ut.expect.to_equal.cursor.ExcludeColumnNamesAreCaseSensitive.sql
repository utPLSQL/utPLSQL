PROMPT Exclude column names are case sensitive
--Arrange
declare
  l_actual   SYS_REFCURSOR;
  l_expected SYS_REFCURSOR;
  l_result   integer;
  l_results_details ut_expectation_results;
begin
--Act
  open l_actual   for select 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col" from dual;
  open l_expected for select 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col" from dual;
  ut.expect(l_actual).to_equal(l_expected, a_exclude=>'A_COLUMN,Some_Col');
  l_result :=  ut_expectation_processor.get_status();
  l_results_details := ut_expectation_processor.get_failed_expectations();
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and l_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    for i in 1 .. l_results_details.count loop
      if l_results_details(i).status != ut_utils.tr_success then
        dbms_output.put_line( l_results_details(i).message );
      end if;
    end loop;
  end if;
end;
/
