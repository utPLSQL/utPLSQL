PROMPT Checks that rollback exception does not make run to fail

--Arrange
declare
	simple_test ut_test := ut_test(a_object_name => 'ut_example_tests', a_name => 'ut_commit_test',a_rollback_type => ut_utils.gc_rollback_auto);
	listener ut_event_listener := ut_event_listener(ut_reporters());
begin
--Act
	simple_test.do_execute(listener);
--Assert
	if simple_test.result = ut_utils.gc_success then
    :test_result := ut_utils.gc_success;
	else
		dbms_output.put_line('simple_test.result = '||ut_utils.test_result_to_char(simple_test.result));
	end if;
end;
/
