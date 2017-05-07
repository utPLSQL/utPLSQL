declare
  l_actual    number := 1234;
  l_pattern   varchar2(32767) := '^1234';
  l_modifiers varchar2(32767) := 'i';
  l_result    integer;
begin
--Act
  ut.expect( l_actual ).to_( match(l_pattern, l_modifiers) );
  l_result := ut_expectation_processor.get_status();
--Assert
  if l_result = ut_utils.tr_failure then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||l_actual||''', to match: '''||l_pattern||''' using modifiers:'''||l_modifiers||'''' );
  end if;
end;
/
