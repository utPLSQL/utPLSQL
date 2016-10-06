PROMPT Puts 'NULL' into assert results when actual value is null

--Arrange
declare
  l_results      ut_objects_list;
begin
--Act
  ut.expect(to_char(NULL)).to_be_equal('abc');
  l_results :=  ut_assert_processor.get_asserts_results();
--Assert
  if treat(l_results(1) as ut_assert_result).actual_value_string = 'NULL' then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: actual_value_string to be NULL, but got '''||treat(l_results(1) as ut_assert_result).actual_value_string||'''' );
  end if;
end;
/

