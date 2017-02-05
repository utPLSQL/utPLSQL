--Arrange
declare
  l_actual   &&1 := &&2;
  l_result   integer;
begin
--Act
  ut.expect(l_actual).&&3();
  l_result :=  ut_assert_processor.get_aggregate_asserts_result();
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and l_result = &&4 then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line(q'[expected: &&2 &&3]' );
  end if;
end;
/
