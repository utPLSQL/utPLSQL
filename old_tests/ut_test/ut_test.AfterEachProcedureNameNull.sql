PROMPT Does not invoke aftereach procedure when aftereach procedure name for a test is null

--Arrange
declare
  simple_test ut_test := ut_test(
    a_object_name => 'ut_example_tests'
    ,a_name => 'ut_passing_test'
  );
begin
  simple_test.after_each_list := ut_executables(ut_executable(user, 'ut_example_tests', '', ut_utils.gc_after_each));
--Act
  simple_test.do_execute();
--Assert
  if ut_example_tests.g_char2 = 'a' then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: ut_example_tests.g_char = ''a'', got: '||ut_example_tests.g_char2 );
  end if;
end;
/
