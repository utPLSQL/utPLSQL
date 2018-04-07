PROMPT Does not execute test and reports error when test setup procedure name for a test is invalid

--Arrange
declare
  simple_test ut_test := ut_test(
     a_before_test_proc_name => 'invalid setup name'
    ,a_object_name => 'ut_example_tests'
    ,a_name => 'ut_exampletest'
  );
  listener ut_event_listener := ut_event_listener(ut_reporters());
begin
  ut_example_tests.g_char := null;
--Act
  simple_test.do_execute(listener);
--Assert
  if simple_test.result = ut_utils.gc_error and ut_example_tests.g_char is null then
    :test_result := ut_utils.gc_success;
  end if;
end;
/
