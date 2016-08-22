PROMPT Trims a name for standalone program

--Arrange
declare
  l_expected varchar2(20) := 'some_procedure';
  l_result varchar2(20);
begin
--Act
  l_result :=  ut_metadata.form_name(NULL, ' '||l_expected||' ');
--Assert
  if l_result = l_expected then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||l_expected||''', got: '''||l_result||'''' );
  end if;
end;
/
