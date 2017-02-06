PROMPT Puts Object structure as string into the Assert
--Arrange
declare
  l_expected department$ := department$('HR');
  l_actual   department$ := department$('it');
  l_result   integer;
  l_assert_result  ut_assert_result;
begin
--Act
  ut.expect( anydata.convertObject(l_actual) ).to_equal( anydata.convertObject(l_expected) );
  l_assert_result := treat(ut_assert_processor.get_asserts_results()(1) as ut_assert_result);

--Assert
  if l_assert_result.expected_value_string like  '''<DEPARTMENT%>
  <DEPT_NAME>HR</DEPT_NAME>
</DEPARTMENT%>
'''
    and l_assert_result.actual_value_string like '''<DEPARTMENT%>
  <DEPT_NAME>it</DEPT_NAME>
</DEPARTMENT%>
'''
   then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line( l_assert_result.expected_value_string );
    dbms_output.put_line( l_assert_result.actual_value_string );
  end if;
end;
/
