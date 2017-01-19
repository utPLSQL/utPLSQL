PROMPT ut_output_buffered.get_lines Returns no rows if noting was sent

declare
  l_rows         integer;
  l_output       ut_output_buffered := ut_output_buffered();
begin
  select count(1) into l_rows from table( l_output.get_lines('dummy output id') );
  if l_rows = 0 then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('Expected 0 rows, got '||l_rows||' rows');
  end if;
end;
/
