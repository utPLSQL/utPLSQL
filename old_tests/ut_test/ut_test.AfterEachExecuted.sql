PROMPT Invoke aftereach procedure

--Arrange
declare
  simple_test ut_test := ut_test(
    a_object_name  => 'ut_example_tests',
    a_name     => 'ut_passing_test',
    a_line_no => null
  );
begin
  simple_test.after_each_list := ut_executables(ut_executable(user, 'ut_example_tests', 'aftereach', ut_utils.gc_after_each));
--Act
  simple_test.do_execute();
--Assert
  if simple_test.result = ut_utils.gc_success and ut_example_tests.g_char2 = 'F' then
    :test_result := ut_utils.gc_success;
  end if;
end;
/

