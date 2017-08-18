--Arrange
declare
  l_result       integer;
  l_dummy        integer;
  l_output       ut_output_buffer_base := ut_output_table_buffer();
  l_start_time   timestamp := systimestamp;
  l_wait_seconds integer := 1;
begin
  --Act
  l_output.send_line(lpad('a text',4000,',a text'));

  select count(*) into l_dummy from table( l_output.get_lines( a_initial_timeout => 0, a_timeout_sec => l_wait_seconds ));
  l_result := round(extract(second from (systimestamp - l_start_time)));

  --Assert
  ut.expect(l_result).to_equal(l_wait_seconds);

  if ut_expectation_processor.get_status = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line(ut_expectation_processor.get_expectations_results()(1).get_result_clob);
  end if;
end;
/
