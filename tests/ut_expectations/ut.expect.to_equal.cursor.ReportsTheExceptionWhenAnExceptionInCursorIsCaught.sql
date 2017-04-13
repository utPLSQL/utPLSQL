--Arrange
declare
  l_actual   sys_refcursor;
  l_failed   boolean := false;
begin
--Act
  open l_actual for select 1/0 as error_column from dual connect by level < 10;
  begin
    ut.expect(l_actual).to_( be_empty());
  exception
    when others then
      if sqlcode = -19202 then
        l_failed := true;
      end if;
  end;
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success
    and l_failed then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected an exception to be thrown but nothing happened.' );
  end if;
end;
/
