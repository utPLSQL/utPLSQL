PROMPT ut_output_buffered.gt_lines Returns lines that have been sent to the output

declare
  l_output   ut_output_buffered := ut_output_buffered();
  l_expected varchar2(4000) := 'a test line';
begin
  --Act - open the pipe
  l_output.send_line(l_expected);
  l_output.send_line(l_expected);
  --Assert - check that pipe exists
  for i in (select column_value as result from table( l_output.get_lines(l_output.output_id) )) loop
    if i.result = l_expected then
      :test_result := ut_utils.tr_success;
    else
      :test_result := ut_utils.tr_failure;
    end if;
  end loop;
end;
/
