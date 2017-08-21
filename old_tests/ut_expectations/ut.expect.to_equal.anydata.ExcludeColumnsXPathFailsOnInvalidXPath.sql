--Arrange
declare
  l_actual   ut_key_value_pair;
  l_expected ut_key_value_pair;
  l_result   integer;
  e_xpath_error exception;
  pragma exception_init (e_xpath_error,-31011);
begin
--Act
  l_actual   := ut_key_value_pair(key=>'A',value=>'1');
  l_expected := ut_key_value_pair(key=>'A',value=>'0');
  begin
    ut.expect(anydata.convertObject(l_actual)).to_equal(anydata.convertObject(l_expected), a_exclude=>'/ROW/A_COLUMN,//Some_Col');
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
