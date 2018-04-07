PROMPT Does not execute test and reports error when test teardown procedure name for a test is invalid

--Arrange
declare
  simple_test ut_test := ut_test(
    a_object_name => 'ut_example_tests'
    ,a_name => 'ut_exampletest'
  );
begin
  simple_test.after_test_list := ut_executables(ut_executable(user, 'ut_example_tests', 'invalid setup name', ut_utils.gc_after_test));
  ut_example_tests.g_char := 'x';
--Act
  simple_test.do_execute();
--Assert
  if ut_example_tests.g_char = 'x' and simple_test.result = ut_utils.gc_error then
    :test_result := ut_utils.gc_success;
  end if;
end;
/
