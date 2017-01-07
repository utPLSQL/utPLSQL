PROMPT Does not execute test and reports error when test teardown procedure name for a test is invalid

--Arrange
declare
  simple_test ut_test := ut_test(
    a_after_test_proc_name => 'invalid setup name'
    ,a_object_name => 'ut_example_tests'
    ,a_name => 'ut_exampletest'
  );
  listener ut_event_listener := ut_event_listener(ut_reporters());
begin
  ut_example_tests.g_char := 'x';
--Act
  simple_test.do_execute(listener);
--Assert
  if ut_example_tests.g_char = 'x' and simple_test.result = ut_utils.tr_error then
    :test_result := ut_utils.tr_success;
  end if;
end;
/
