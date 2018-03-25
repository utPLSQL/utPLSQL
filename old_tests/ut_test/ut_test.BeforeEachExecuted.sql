PROMPT Invoke beforeeach procedure

--Arrange
declare
  simple_test ut_test := ut_test(
    a_object_name  => 'ut_example_tests'
    ,a_name        => 'ut_passing_test'
  );
begin
  simple_test.before_each_list := ut_executables(ut_executable(simple_test, 'beforeeach', ut_utils.gc_before_each));
  ut_example_tests.g_number2 := null;
--Act
  simple_test.do_execute();
--Assert
  if ut_example_tests.g_number2 = 1 then
    :test_result := ut_utils.tr_success;
  end if;
end;
/

