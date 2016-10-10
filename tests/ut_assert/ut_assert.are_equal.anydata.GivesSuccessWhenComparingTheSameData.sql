PROMPT Gives a success when comparing equal oracle objects
--Arrange
create or replace type department$ as object(
   dept_name varchar2(30)
);
/

declare
  l_expected department$ := department$('hr');
  l_actual   department$ := department$('hr');
  l_result   integer;
begin
--Act
  ut_assert.are_equal( anydata.convertObject(l_expected), anydata.convertObject(l_actual) );
  l_result :=  ut_assert.get_aggregate_asserts_result();
--Assert
  if l_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||ut_utils.tr_success||''', got: '''||l_result||'''' );
  end if;
end;
/

--Cleanup
drop type department$;
