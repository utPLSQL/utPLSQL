PROMPT Does not execute test and reports error when test setup procedure name for a test is invalid

--Arrange
declare
  simple_test ut_test := ut_test(
    a_setup_procedure => 'invalid setup name'
    ,a_object_name => 'ut_example_tests'
    ,a_test_procedure => 'ut_exampletest'
  );
begin
  ut_example_tests.g_char := null;
--Act
  simple_test.execute();
--Assert
  if simple_test.result = ut_utils.tr_error and ut_example_tests.g_char is null then
    :test_result := ut_utils.tr_success;
  end if;
end;
/
