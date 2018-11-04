PROMPT Does not execute test and reports error when test aftereach procedure name for a test is invalid

--Arrange
declare
  simple_test ut_test := ut_test(
    a_object_name => 'ut_example_tests',
    a_name => 'ut_exampletest',
    a_line_no => null
  );
begin
  simple_test.after_each_list := ut_executables(ut_executable(user, 'ut_example_tests', 'invalid setup name', ut_utils.gc_after_each));
  ut_example_tests.g_char := 'x';
  ut_example_tests.g_char2 := 'x';
--Act
  simple_test.do_execute();
--Assert
  if ut_example_tests.g_char2 = 'x' and simple_test.result = ut_utils.gc_error then
    :test_result := ut_utils.gc_success;
  end if;
end;
/
