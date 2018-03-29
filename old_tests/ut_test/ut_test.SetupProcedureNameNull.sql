PROMPT Does not invoke setup procedure when setup procedure name for a test is null

--Arrange
declare
  simple_test ut_test := ut_test(
     a_object_name => 'ut_example_tests'
    ,a_name => 'ut_passing_test'
  );
begin
  simple_test.before_test_list := ut_executables(ut_executable(user, 'ut_example_tests', null, ut_utils.gc_before_test));
  ut_example_tests.g_number := null;
--Act
  simple_test.do_execute();
--Assert
  if ut_example_tests.g_number is null then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: ut_example_tests.g_number is null, got: '||ut_example_tests.g_number );
  end if;
end;
/
