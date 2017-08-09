--Arrange
declare
  l_result   varchar2(4000);
  l_expected varchar2(4000);
  l_reporter ut_reporter_base := ut_documentation_reporter();
begin
--Act
  l_expected := lpad('a text',4000,',a text');
  ut_output_buffer.send_line(l_reporter, l_expected);

  select text into l_result from ut_output_buffer_tmp where reporter_id = l_reporter.reporter_id;

  ut.expect(l_result).to_equal(l_expected);
  if ut_expectation_processor.get_status = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line(ut_expectation_processor.get_expectations_results()(1).get_result_clob);
  end if;

  delete from ut_output_buffer_tmp where reporter_id = l_reporter.reporter_id;
  commit;
end;
/
