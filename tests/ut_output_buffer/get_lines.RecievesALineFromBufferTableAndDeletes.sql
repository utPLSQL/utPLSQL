--Arrange
declare
  l_result   varchar2(4000);
  l_remaining integer;
  l_expected varchar2(4000);
  l_output   ut_output_buffer_base := ut_output_table_buffer();
begin
  --Act
  l_expected := lpad('a text',4000,',a text');
  l_output.send_line(l_expected);

  select * into l_result from table(l_output.get_lines(a_timeout_sec => 0));
  select count(1) into l_remaining from ut_output_buffer_tmp where output_id = l_output.output_id;

  --Assert
  ut.expect(l_result).to_equal(l_expected);
  ut.expect(l_remaining).to_equal(0);

  if ut_expectation_processor.get_status = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line(ut_expectation_processor.get_expectations_results()(1).get_result_clob);
  end if;

  delete from ut_output_buffer_tmp where output_id = l_output.output_id;
  commit;
exception
  when others then
    delete from ut_output_buffer_tmp where output_id = l_output.output_id;
    commit;
    raise;
end;
/
