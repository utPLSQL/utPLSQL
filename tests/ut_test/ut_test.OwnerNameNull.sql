PROMPT Executes test in current schema when test owner name for a test is null

--Arrange
declare
  simple_test ut_test:= ut_test(a_owner_name => null, a_object_name => 'ut_example_tests', a_test_procedure => 'ut_passing_test');
begin
--Act
  simple_test.execute();
--Assert
  if ut_example_tests.g_char = 'a' then
    :test_result := simple_test.result;
  end if;
end;
/
