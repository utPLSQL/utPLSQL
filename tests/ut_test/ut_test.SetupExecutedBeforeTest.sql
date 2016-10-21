PROMPT Invoke setup procedure before test when setup procedure name is defined

--Arrange
declare
  simple_test ut_test := ut_test(
    a_object_name        => 'ut_example_tests'
    ,a_test_procedure     => 'ut_passing_test'
    ,a_setup_procedure    => 'setup'
  );
begin
  ut_example_tests.g_number := null;
--Act
  simple_test.do_execute();
--Assert
  if ut_example_tests.g_number = 1 then
    :test_result := ut_utils.tr_success;
  end if;
end;
/

