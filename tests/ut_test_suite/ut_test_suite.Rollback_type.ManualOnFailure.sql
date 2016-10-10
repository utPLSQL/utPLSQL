PROMPT Test suite manual transaction control on failure

--Arrange
declare
  l_suite ut_test_suite;
  l_test ut_test;
  l_parsing_result ut_annotations.typ_annotated_package;
  l_expected ut_annotations.typ_annotated_package;
  l_ann_param ut_annotations.typ_annotation_param;
  l_cnt number;

begin
  
  delete from ut$test_table;

  l_test := ut_test(a_object_name => 'ut_transaction_control',a_test_procedure => 'test_failure', a_rollback_type => ut_utils.gc_rollback_manual);
  l_suite := ut_test_suite(a_suite_name => 'Suite name', a_object_name => 'UT_TRANSACTION_CONTROL', a_items => ut_objects_list(l_test), a_rollback_type => ut_utils.gc_rollback_manual);
  l_suite.set_suite_setup('ut_transaction_control','setup');

--Act  
  l_suite.execute;
  
  ut_assert.clear_asserts;

--Assert  
  --even if the manual mode is used and the feilure occurred all the changes in the test procedure are rollbacked by DB
  --http://asktom.oracle.com/pls/apex/f?p=100:12:0::NO::P12_ORIG,P12_PREV_PAGE,P12_QUESTION_ID:Y,1,9532007800346890501
  ut_assert.this(ut_transaction_control.count_rows('t')=0);
  ut_assert.this(ut_transaction_control.count_rows('s')>0);

  if ut_assert.get_aggregate_asserts_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  end if;

end;
/
