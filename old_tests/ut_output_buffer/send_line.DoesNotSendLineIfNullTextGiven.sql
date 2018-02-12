--Arrange
declare
  l_result integer;
  l_output   ut_output_buffer_base := ut_output_table_buffer();
begin
  delete from ut_output_buffer_tmp;
  --Act
  l_output.send_line(null);

  select count(1) into l_result from ut_output_buffer_tmp;

  --Assert
  ut.expect(l_result).to_equal(0);
  if ut_expectation_processor.get_status = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line(ut_expectation_processor.get_failed_expectations()(1).get_result_clob);
  end if;

end;
/
