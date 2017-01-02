PROMPT Executes test in current schema when test owner name for a test is null

--Arrange
declare
  simple_test ut_test:= ut_test(a_object_owner => null, a_object_name => 'ut_example_tests', a_name => 'ut_passing_test');
  listener ut_execution_listener := ut_execution_listener(ut_reporters());
begin
--Act
  simple_test.do_execute(listener);
--Assert
  if ut_example_tests.g_char = 'a' then
    :test_result := simple_test.result;
  end if;
end;
/
