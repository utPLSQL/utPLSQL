PROMPT Gives The Provided Text As Message in the test result

--Arrange
declare
  l_results      ut_objects_list;
  l_test_message varchar2(30) := 'A test message';
begin
--Act
  ut_assert.are_equal(l_test_message, 1, 1);
  l_results :=  ut_assert.get_asserts_results();
--Assert
  if treat(l_results(1) as ut_assert_result).message like '%'||l_test_message||'%' then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||treat(l_results(1) as ut_assert_result).message||''' to match
''%'||l_test_message||'%''' );
  end if;
end;
/
