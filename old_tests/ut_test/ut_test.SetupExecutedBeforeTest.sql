PROMPT Invoke setup procedure before test when setup procedure name is defined

--Arrange
declare
  simple_test ut_test := ut_test(
    a_object_name            => 'ut_example_tests',
    a_name        => 'ut_passing_test',
    a_line_no => null
  );
begin
  simple_test.before_test_list := ut_executables(ut_executable(user, 'ut_example_tests', 'setup', ut_utils.gc_before_test));
  ut_example_tests.g_number := null;
--Act
  simple_test.do_execute();
--Assert
  if ut_example_tests.g_number = 1 then
    :test_result := ut_utils.gc_success;
  end if;
end;
/

