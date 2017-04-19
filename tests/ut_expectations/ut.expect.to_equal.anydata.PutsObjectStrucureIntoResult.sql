PROMPT Puts Object structure as string into the expectation
--Arrange
declare
  l_expected department$ := department$('HR');
  l_actual   department$ := department$('it');
  l_result   integer;
  l_expectation_result  ut_expectation_result;
begin
--Act
  ut.expect( anydata.convertObject(l_actual) ).to_equal( anydata.convertObject(l_expected) );
  l_expectation_result := treat(ut_expectation_processor.get_expectations_results()(1) as ut_expectation_result);

--Assert
  if l_expectation_result.expected_value_string like  '''<DEPARTMENT%>
  <DEPT_NAME>HR</DEPT_NAME>
</DEPARTMENT%>
'''
    and l_expectation_result.actual_value_string like '''<DEPARTMENT%>
  <DEPT_NAME>it</DEPT_NAME>
</DEPARTMENT%>
'''
   then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line( l_expectation_result.expected_value_string );
    dbms_output.put_line( l_expectation_result.actual_value_string );
  end if;
end;
/
