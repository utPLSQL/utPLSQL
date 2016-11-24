PROMPT ut_output_dbms_output.get_clob_lines Returns lines that have been sent to the output

declare
  l_output   ut_output_dbms_output := ut_output_dbms_output();
  l_expected clob;
begin
  l_expected := lpad('a',32000,'a');
  --Act - open the pipe
  l_output.send_clob(l_expected);
  l_output.send_clob(l_expected);
  --Assert - check that pipe exists
  for i in (select column_value as result from table( l_output.get_clob_lines(null) )) loop
    if i.result = l_expected then
      :test_result := ut_utils.tr_success;
    else
      :test_result := ut_utils.tr_failure;
    dbms_output.put_line('Expected '||length(l_expected)||' characters, got '||length(i.result));
    end if;
  end loop;
end;
/
