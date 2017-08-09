PROMPT Puts Object structure as string into the Assert
--Arrange
declare
  l_actual   department$ := department$('it');
  l_expected department$ := department$('HR');
  l_result   integer;
  l_assert_result  ut_expectation_result;
begin
--Act
  ut.expect( anydata.convertObject(l_actual) ).to_equal( anydata.convertObject(l_expected) );
  l_assert_result := treat(ut_expectation_processor.get_expectations_results()(1) as ut_expectation_result);

--Assert
  if l_assert_result.message like  q'[Actual:%
    <DEPARTMENT_x0024_>
      <DEPT_NAME>it</DEPT_NAME>
    </DEPARTMENT_x0024_>%
was expected to equal:%
    <DEPARTMENT_x0024_>
      <DEPT_NAME>HR</DEPT_NAME>
    </DEPARTMENT_x0024_>%]'
  then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line( l_assert_result.message );
  end if;
end;
/
