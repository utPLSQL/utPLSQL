var test_result number
exec :test_result := null;

whenever sqlerror exit success

begin
if NOT &1..gc_enabled then
--RAISE_APPLICATION_ERROR(-20000,'&1 is not enabled');
       dbms_output.put_line('&1 is not enabled. skipping...');
RAISE NO_DATA_FOUND;
end if;
end;
/

whenever sqlerror exit failure rollback


prompt Executing test: &2
--exec dbms_output.put_line(lpad('-',60,'-'));
exec :test_start_time := dbms_utility.get_time;
@@&2

declare
  l_duration_str varchar2(300) := ', executed in: '||((dbms_utility.get_time - :test_start_time)/100)||' second(s)';
begin
  case
     when :test_result = ut_utils.tr_success then
       dbms_output.put_line('  Success'||l_duration_str);
       :successes_count := :successes_count + 1;
     else
       dbms_output.put_line('  Failure'||l_duration_str);
       :failures_count := :failures_count + 1;
  end case;
end;
/

begin
  ut_assert_processor.clear_asserts;
  ut_assert_processor.clear_asserts;
end;
/

prompt
