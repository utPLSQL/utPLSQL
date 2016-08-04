PROMPT Reports error when unit test package name for a test is null

--Arrange
declare
	simple_test ut_test := ut_test(a_object_name => null, a_test_procedure => 'ut_passing_test');
begin
--Act
	simple_test.execute();
--Assert
	if simple_test.result = ut_utils.tr_error then
    :test_result := ut_utils.tr_success;
	end if;
end;
/
