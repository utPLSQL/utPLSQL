prompt
prompt ************************************************************************************
begin
  dbms_output.put_line(
    'tests: '||to_char(:failures_count + :successes_count)
    ||' , success: '||:successes_count
    ||' , failure: '||:failures_count
    ||' , executed in '||((dbms_utility.get_time - :run_start_time)/100)||' second(s)'
  );
  if :failures_count > 0 then
    dbms_output.put_line( '  Some tests have failed, please review results!');
  else
    dbms_output.put_line( '  All tests have passed.');
  end if;
end;
/
