PROMPT ut_output_dbms_pipe.get_lines Times out after a given time

declare
  l_expected_time integer := 1;
  l_time          date := sysdate;
  l_result_time  integer;
  l_rows         integer;
  l_output       ut_output_dbms_pipe := ut_output_dbms_pipe();
begin
  select count(1) into l_rows from table( l_output.get_lines('dummy output id',l_expected_time) );
  l_result_time := (sysdate - l_time) * 24 * 60 * 60;
  if l_result_time = l_expected_time and l_rows = 0 then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('Expected '||l_expected_time||' seconds and 0 rows, got '||l_result_time||' seconds and '||l_rows||' rows');
  end if;
end;
/
