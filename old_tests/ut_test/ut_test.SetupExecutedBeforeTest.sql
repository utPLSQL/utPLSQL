PROMPT Invoke setup procedure before test when setup procedure name is defined

--Arrange
declare
  simple_test ut_test := ut_test(
    a_object_name            => 'ut_example_tests'
    ,a_name        => 'ut_passing_test'
    ,a_before_test_proc_name => 'setup'
  );
  listener ut_event_listener := ut_event_listener(ut_reporters());
begin
  ut_example_tests.g_number := null;
--Act
  simple_test.do_execute(listener);
--Assert
  if ut_example_tests.g_number = 1 then
    :test_result := ut_utils.gc_success;
  end if;
end;
/

