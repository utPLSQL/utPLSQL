PROMPT Ignore whole suite by ignore flag

--Arrange
declare
  l_suite ut_test_suite;
  l_test ut_test;
  l_parsing_result ut_annotations.typ_annotated_package;
  l_expected ut_annotations.typ_annotated_package;
  l_ann_param ut_annotations.typ_annotation_param;
  l_cnt number;
  l_reporter ut_reporter := ut_documentation_reporter();
begin
  l_test := ut_test(a_object_name => 'UT_FAIL_SUITE',a_test_procedure => 'TEST');
  l_suite := ut_test_suite(a_suite_name => 'Suite name', a_object_name => 'UT_FAIL_SUITE', a_items => ut_objects_list(l_test));
  l_suite.set_suite_setup(a_object_name => 'UT_FAIL_SUITE', a_proc_name => 'SUITE_SETUP');
  l_suite.set_suite_teardown(a_object_name => 'UT_FAIL_SUITE', a_proc_name => 'SUITE_TEARDOWN');

--Act  
  UT_FAIL_SUITE.g_fail_setup := true;
  l_suite.do_execute(l_reporter,null);
  
  ut_assert_processor.clear_asserts;

--Assert  
  ut.expect(l_suite.result).to_equal(ut_utils.tr_error);

  if ut_assert_processor.get_aggregate_asserts_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  end if;
  
  ut_assert_processor.clear_asserts;
end;
/
