declare
  l_date date := to_date('2017090806:40:12','yyyymmddhh24:mi:ss');
  l_date_string varchar2(100) := to_char(l_date);
  l_result   integer;
begin
  l_date_string := to_char(l_date);

  --consecutive calls to set/reset does not impact that behavior
  ut.set_nls;
  ut.set_nls;
  ut.reset_nls;
  ut.expect(to_char(l_date)).to_equal(l_date_string);

  l_result :=  ut_expectation_processor.get_aggregate_asserts_result();

  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and l_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '''||l_date_string||''', got: '''||to_char(l_date)||'''' );
  end if;
end;
/
