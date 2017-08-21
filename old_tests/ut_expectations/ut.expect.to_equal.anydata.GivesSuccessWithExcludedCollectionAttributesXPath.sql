--Arrange
declare
  l_actual   ut_key_value_pairs;
  l_expected ut_key_value_pairs;
  l_result   integer;
  l_results_details ut_expectation_results;
begin
--Act
  l_actual   := ut_key_value_pairs(ut_key_value_pair(key=>'A',value=>'1'), ut_key_value_pair(key=>'B',value=>'2'));
  l_expected := ut_key_value_pairs(ut_key_value_pair(key=>'A',value=>'0'), ut_key_value_pair(key=>'B',value=>'1'));

  ut.expect(anydata.convertCollection(l_actual)).to_equal(
    anydata.convertCollection(l_expected),
    a_exclude=>ut_varchar2_list('/UT_KEY_VALUE_PAIRS/UT_KEY_VALUE_PAIR/VALUE')
  );
  l_result :=  ut_expectation_processor.get_status();
  l_results_details := ut_expectation_processor.get_expectations_results();
--Assert
  if nvl(:test_result, ut_utils.tr_success) = ut_utils.tr_success and l_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    for i in 1 .. l_results_details.count loop
      if l_results_details(i).status != ut_utils.tr_success then
        dbms_output.put_line( l_results_details(i).message );
      end if;
    end loop;
  end if;
end;
/
