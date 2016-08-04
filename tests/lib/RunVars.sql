var successes_count number
var failures_count number
var test_result number
var run_start_time number
var test_start_time number
exec :successes_count := 0;
exec :failures_count := 0;
exec :test_result := 0;
exec :run_start_time := dbms_utility.get_time;
