--Arrange
declare
  l_actual   &&1 := &&2;
  l_expected &&1 := &&3;
  l_results      ut_objects_list;
begin
--Act
  ut.expect(l_actual).to_equal(l_expected);
  l_results :=  ut_assert_processor.get_asserts_results();
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and treat(l_results(1) as ut_assert_result).&4 = 'NULL' then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: &4 to be NULL, but got '''||treat(l_results(1) as ut_assert_result).&4||'''' );
  end if;
end;
/
