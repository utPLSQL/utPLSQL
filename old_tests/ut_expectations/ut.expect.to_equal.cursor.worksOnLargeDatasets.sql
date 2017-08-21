--Arrange
declare
  l_actual   sys_refcursor;
  l_expected sys_refcursor;
  l_result   integer;
begin
--Act
  open l_actual for select object_name from all_objects where rownum <=1100;
  open l_expected for select object_name from all_objects where rownum <=1100;
  ut.expect(l_actual).to_equal(l_expected);

--Assert
  l_result :=  ut_expectation_processor.get_status();
--Assert
  if l_result = ut_utils.tr_success then
      :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected 1 data and got: '||l_result );
  end if;
end;
/
