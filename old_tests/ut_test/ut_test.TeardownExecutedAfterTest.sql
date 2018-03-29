PROMPT Invoke teardown procedure after test when teardown procedure name is defined

--Arrange
declare
  simple_test ut_test := ut_test(
    a_object_name         => 'ut_example_tests'
    ,a_name     => 'ut_passing_test'
  );
begin
  simple_test.after_test_list := ut_executables(ut_executable(user, 'ut_example_tests', 'teardown', ut_utils.gc_after_test));
--Act
  simple_test.do_execute();
--Assert
  if simple_test.result = ut_utils.tr_success and ut_example_tests.g_char is null then
    :test_result := ut_utils.tr_success;
  end if;
end;
/

