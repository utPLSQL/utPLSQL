declare
  l_actual    number := 1234;
  l_pattern   varchar2(32767) := '1234';
  l_escape_char varchar2(32767) := '';
  l_result    integer;
begin
--Act
  ut.expect( l_actual ).to_( be_like(l_pattern, l_escape_char) );
  l_result := ut_expectation_processor.get_status();
--Assert
  if l_result = ut_utils.gc_failure then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line('expected: '''||l_actual||''', to be like '''||l_pattern||''' escape'''||l_escape_char||'''' );
  end if;
end;
/
