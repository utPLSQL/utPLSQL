PROMPT Invoke aftereach procedure

--Arrange
declare
  simple_test ut_test := ut_test(
    a_object_name         => 'ut_example_tests'
    ,a_name     => 'ut_passing_test'
    ,a_after_each_proc_name => 'aftereach'
  );
  listener ut_event_listener := ut_event_listener(ut_reporters());
begin
--Act
  simple_test.do_execute(listener);
--Assert
  if simple_test.result = ut_utils.gc_success and ut_example_tests.g_char2 = 'F' then
    :test_result := ut_utils.gc_success;
  end if;
end;
/

