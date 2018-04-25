--Arrange
declare
  l_result   varchar2(4000);
  l_expected varchar2(4000);
  l_output   ut_output_buffer_base := ut_output_table_buffer();
begin
  --Act
  l_expected := lpad('a text',4000,',a text');
  l_output.send_line(l_expected);

  select text into l_result from ut_output_buffer_tmp where output_id = l_output.output_id;

  --Assert
  ut.expect(l_result).to_equal(l_expected);
  if ut_expectation_processor.get_status = ut_utils.gc_success then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line(ut_expectation_processor.get_failed_expectations()(1).get_result_clob);
  end if;

  delete from ut_output_buffer_tmp where output_id = l_output.output_id;
  commit;
end;
/
