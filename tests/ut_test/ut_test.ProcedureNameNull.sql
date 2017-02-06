PROMPT Reports error when test procedure name for a test is null

--Arrange
declare
  simple_test ut_test := ut_test(a_object_name => 'ut_example_tests', a_name => null);
  listener ut_event_listener := ut_event_listener(ut_reporters());
begin
--Act
  simple_test.do_execute(listener);
--Assert
  if simple_test.result = ut_utils.tr_error then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('simple_test.result = '||ut_utils.test_result_to_char(simple_test.result));
  end if;
end;
/
