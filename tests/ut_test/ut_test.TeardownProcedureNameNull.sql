PROMPT Does not invoke setup procedure when setup procedure name for a test is null

--Arrange
declare
  simple_test ut_test := ut_test(
    a_teardown_procedure => null
    ,a_object_name => 'ut_example_tests'
    ,a_test_procedure => 'ut_passing_test'
  );
begin
--Act
  simple_test.do_execute();
--Assert
  if ut_example_tests.g_char = 'a' then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: ut_example_tests.g_char is null, got: '||ut_example_tests.g_char );
  end if;
end;
/
