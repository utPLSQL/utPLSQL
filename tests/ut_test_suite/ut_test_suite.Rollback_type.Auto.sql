PROMPT Test suite auto transaction control

--Arrange
declare
  l_suite ut_suite;
  l_test ut_test;
  l_parsing_result ut_annotations.typ_annotated_package;
  l_expected ut_annotations.typ_annotated_package;
  l_ann_param ut_annotations.typ_annotation_param;
  l_cnt number;
  l_listener ut_event_listener := ut_event_listener(ut_reporters());
begin

  delete from ut$test_table;

  l_test := ut_test(a_object_name => 'ut_transaction_control',a_name => 'test', a_rollback_type => ut_utils.gc_rollback_auto);
  l_suite := ut_suite(a_description => 'Suite name', a_name => 'UT_TRANSACTION_CONTROL', a_object_name => 'UT_TRANSACTION_CONTROL', a_rollback_type => ut_utils.gc_rollback_auto,
             a_before_all_proc_name => 'setup');
  l_suite.add_item(l_test);

--Act
  l_suite.do_execute(l_listener);

  ut_assert_processor.clear_asserts;

--Assert
  ut.expect(ut_transaction_control.count_rows('t')).to_equal(0);
  ut.expect(ut_transaction_control.count_rows('s')).to_equal(0);

  if ut_assert_processor.get_aggregate_asserts_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  end if;

end;
/
