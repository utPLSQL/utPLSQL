PROMPT Does not invoke teardown procedure when teardown procedure name for a test is null

--Arrange
declare
  simple_test ut_test := ut_test(
    a_object_name => 'ut_example_tests',
    a_name => 'ut_passing_test',
    a_line_no => null
  );
begin
  simple_test.after_test_list := ut_executables(ut_executable(user, 'ut_example_tests', null, ut_utils.gc_after_test));
--Act
  simple_test.do_execute();
--Assert
  if ut_example_tests.g_char = 'a' then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line('expected: ut_example_tests.g_char = ''a'', got: '''||ut_example_tests.g_char||'''' );
  end if;
end;
/
