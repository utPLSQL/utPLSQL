PROMPT Invoke teardown procedure after test when teardown procedure name is defined

--Arrange
declare
  simple_test ut_test := ut_test(
    a_object_name         => 'ut_example_tests'
    ,a_test_procedure     => 'ut_passing_test'
    ,a_teardown_procedure => 'teardown'
  );
begin
--Act
  simple_test.execute();
--Assert
  if simple_test.result = ut_utils.tr_success and ut_example_tests.g_char is null then
    :test_result := ut_utils.tr_success;
  end if;
end;
/

