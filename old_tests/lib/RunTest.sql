var test_result number
exec :test_result := null;

prompt Executing test: &1
exec :test_start_time := dbms_utility.get_time;
@@&1
set serveroutput on size unlimited format truncated
set termout on
declare
  l_duration_str varchar2(300) := ', executed in: '||((dbms_utility.get_time - :test_start_time)/100)||' second(s)';
begin
  case
     when :test_result = ut_utils.tr_success then
        :successes_count := :successes_count + 1;
     else
       dbms_output.put_line('---------------------------------------');
       dbms_output.put_line('  Failure'||l_duration_str);
       dbms_output.put_line('---------------------------------------');
       :failures_count := :failures_count + 1;
  end case;
end;
/

rollback;
begin
  ut_expectation_processor.clear_expectations;
  ut_utils.cleanup_temp_tables;                                            
end;
/

