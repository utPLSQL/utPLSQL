declare
  l_actual    &1 := &2;
  l_pattern   varchar2(32767) := '&3';
  l_escape_char varchar2(32767) := '&4';
  l_result    integer;
begin
--Act
  ut.expect( l_actual ).to_be_like(l_pattern, l_escape_char);
  l_result := ut_expectation_processor.get_aggregate_asserts_result();
--Assert
  if l_result = &5 then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||l_actual||''', to be like '''||l_pattern||''' escape'''||l_escape_char||'''' );
  end if;
end;
/
