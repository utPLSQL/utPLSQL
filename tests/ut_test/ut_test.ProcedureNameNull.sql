PROMPT Reports error when test procedure name for a test is null

--Arrange
declare
  simple_test ut_test := ut_test(a_object_name => 'ut_example_tests', a_test_procedure => null);
begin
--Act
  simple_test.do_execute();
--Assert
  if simple_test.result = ut_utils.tr_error then
    :test_result := ut_utils.tr_success;
  end if;
end;
/
