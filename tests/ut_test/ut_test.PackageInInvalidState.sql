PROMPT Reports error when unit test package for a test is in invalid state

--Arrange
create or replace package invalid_package is
		 v_variable non_existing_type;
		 procedure ut_exampletest;
end;
/

declare
	simple_test ut_test := ut_test(a_object_name => 'invalid_package', a_test_procedure => 'ut_exampletest');
begin
--Act
	simple_test.execute();
--Assert
	if simple_test.result = ut_utils.tr_error then
    :test_result := ut_utils.tr_success;
	end if;
end;
/

--Cleanup
drop package invalid_package;
