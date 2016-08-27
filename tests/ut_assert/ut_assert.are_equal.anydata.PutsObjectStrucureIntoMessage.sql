PROMPT Gives a success when comparing equal oracle objects
--Arrange
create or replace type department as object(
   dept_name varchar2(30)
);
/

declare
  l_expected department := department('HR');
  l_actual   department := department('IT');
  l_result   integer;
  assert_results ut_objects_list;
  assert_result  ut_assert_result;
begin
--Act
  ut_assert.are_equal( anydata.convertObject(l_expected), anydata.convertObject(l_actual) );
  ut_assert.process_asserts(assert_results);
  assert_result := treat(assert_results(1) as ut_assert_result);
--Assert
  if assert_result.message like q'[%department(%dept_name => 'HR'%)%]'
    and assert_result.message like q'[%department(%dept_name => 'IT'%)%]'
   then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line( 'assert_result.message does not contain the objects' );
  end if;
end;
/

--Cleanup
drop type department;
