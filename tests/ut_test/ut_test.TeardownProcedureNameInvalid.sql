PROMPT Does not execute test and reports error when test teardown procedure name for a test is invalid

--Arrange
declare
  simple_test ut_test := ut_test(
    a_teardown_procedure => 'invalid setup name'
    ,a_object_name => 'ut_example_tests'
    ,a_test_procedure => 'ut_exampletest'
  );
begin
  ut_example_tests.g_char := 'x';
--Act
  simple_test.do_execute();
--Assert
  if ut_example_tests.g_char = 'x' and simple_test.result = ut_utils.tr_error then
    :test_result := ut_utils.tr_success;
  end if;
end;
/
