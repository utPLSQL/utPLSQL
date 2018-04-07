set termout off
--Arrange
create or replace package invalid_package is
		 v_variable non_existing_type;
		 procedure ut_exampletest;
end;
/
set termout on

declare
	simple_test ut_test := ut_test(a_object_name => 'invalid_package', a_name => 'ut_exampletest');
begin
--Act
	simple_test.do_execute();
--Assert
	if simple_test.result = ut_utils.gc_error then
    :test_result := ut_utils.gc_success;
	else
    dbms_output.put_line('simple_test.result = '||ut_utils.test_result_to_char(simple_test.result));
	end if;
end;
/

set termout off
--Cleanup
drop package invalid_package;
set termout off
