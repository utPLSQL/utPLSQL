--Arrange
begin
  execute immediate 'begin ut_assert.are_equal(null, null); end;';
  dbms_output.put_line('expected an exception but nothing was raised' );
exception
  when others then
    if sqlerrm like '%PLS-00307: too many declarations of ''ARE_EQUAL'' match this call%' then
      :test_result := ut_utils.tr_success;
    else
      dbms_output.put_line( sqlerrm );
    end if;
end;
/
