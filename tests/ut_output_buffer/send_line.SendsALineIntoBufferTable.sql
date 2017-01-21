--Arrange
declare
  l_result   varchar2(4000);
  l_expected varchar2(4000);
  c_id       varchar2(250) := 'a_reporter_id';
begin
--Act
  l_expected := lpad('a text',4000,',a text');
  ut_output_buffer.send_line(c_id, l_expected);

  select text into l_result from ut_output_buffer_tmp where reporter_id = c_id;

  ut.expect(l_result).to_equal(l_expected);
  if ut_assert_processor.get_aggregate_asserts_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line(ut_assert_processor.GET_ASSERTS_RESULTS()(1).get_result_clob);
  end if;

  delete from ut_output_buffer_tmp where reporter_id = c_id;
  commit;
end;
/
