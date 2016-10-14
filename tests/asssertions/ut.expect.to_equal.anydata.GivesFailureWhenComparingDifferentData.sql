PROMPT Gives a success when comparing equal oracle objects
--Arrange
create or replace type department$ as object(
   dept_name varchar2(30)
);
/

declare
  l_expected department$ := department$('HR');
  l_actual   department$ := department$('IT');
  l_result   integer;
begin
--Act
  ut.expect( anydata.convertObject(l_actual) ).to_equal( anydata.convertObject(l_expected) );
  l_result :=  ut_assert_processor.get_aggregate_asserts_result();
--Assert
  if l_result = ut_utils.tr_failure then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.tr_failure||''', got: '''||l_result||'''' );
  end if;
end;
/

--Cleanup
drop type department$;
