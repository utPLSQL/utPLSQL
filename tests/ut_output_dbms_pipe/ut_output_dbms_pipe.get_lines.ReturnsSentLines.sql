PROMPT ut_output_dbms_pipe.get_lines Returns lines that have been sent to the output

declare
  l_output   ut_output_dbms_pipe := ut_output_dbms_pipe();
  l_expected varchar2(4000) := 'a test line';
begin
  l_output.output_id := 'unit_test_pipe';
  -- Arrange - check that pipe does not exist
  l_output.open();
  --Act - open the pipe
  l_output.send_line(l_expected);
  l_output.send_line(l_expected);
  --Assert - check that pipe exists
  for i in (select column_value as result from table( l_output.get_lines(l_output.output_id,0) )) loop
    if i.result = l_expected then
      :test_result := ut_utils.tr_success;
    else
      :test_result := ut_utils.tr_failure;
      dbms_output.put_line('Expected "'||l_expected||'" text, got "'||i.result||'" text');
    end if;
  end loop;
  ut_output_pipe_helper.remove_pipe( l_output.output_id );
end;
/
