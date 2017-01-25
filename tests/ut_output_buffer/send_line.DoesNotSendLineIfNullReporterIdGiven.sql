--Arrange
declare
  l_result integer;
begin
  delete from ut_output_buffer_tmp;
  --Act
  ut_output_buffer.send_line(null,'a text to send');

  select count(1) into l_result from ut_output_buffer_tmp;

  ut.expect(l_result).to_equal(0);
  if ut_assert_processor.get_aggregate_asserts_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line(ut_assert_processor.GET_ASSERTS_RESULTS()(1).get_result_clob);
  end if;

end;
/
