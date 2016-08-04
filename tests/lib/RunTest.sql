var test_result number
exec :test_result := 0;

prompt
prompt Executing test: &1
exec dbms_output.put_line(lpad('-',60,'-'));
exec :test_start_time := dbms_utility.get_time;
@@&1
exec dbms_output.put_line('Took: '||((dbms_utility.get_time - :test_start_time)/100)||' second(s)');

begin
  case
     when :test_result = ut_utils.tr_success then
       dbms_output.put_line('  Success');
       :successes_count := :successes_count + 1;
     else
       dbms_output.put_line('  Failure');
       :failures_count := :failures_count + 1;
  end case;
end;
/
