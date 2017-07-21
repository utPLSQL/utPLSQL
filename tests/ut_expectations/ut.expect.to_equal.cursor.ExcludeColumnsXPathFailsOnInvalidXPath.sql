--Arrange
declare
  l_actual   SYS_REFCURSOR;
  l_expected SYS_REFCURSOR;
  l_result   integer;
  e_xpath_error exception;
  pragma exception_init (e_xpath_error,-31011);
begin
--Act
  open l_actual   for select 'a' as "A_Column", 'c' as A_COLUMN, 'x' SOME_COL, 'd' "Some_Col" from dual;
  open l_expected for select 'a' as "A_Column", 'd' as A_COLUMN, 'x' SOME_COL, 'c' "Some_Col" from dual;
  begin
    ut.expect(l_actual).to_equal(l_expected, a_exclude=>'/ROW/A_COLUMN,//Some_Col');
  exception
    when e_xpath_error then
      l_result := ut_utils.tr_success;
  end;
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and l_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line( 'Expected exception ORA-31011: XML parsing failed, but nothing was raised');
  end if;
end;
/
