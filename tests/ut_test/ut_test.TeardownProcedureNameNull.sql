PROMPT Does not invoke teardown procedure when teardown procedure name for a test is null

--Arrange
declare
  simple_test ut_test := ut_test(
    a_after_test_proc_name => null
    ,a_object_name => 'ut_example_tests'
    ,a_name => 'ut_passing_test'
  );
  listener ut_event_listener := ut_event_listener(ut_reporters());
begin
--Act
  simple_test.do_execute(listener);
--Assert
  if ut_example_tests.g_char = 'a' then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: ut_example_tests.g_char = ''a'', got: '||ut_example_tests.g_char );
  end if;
end;
/
